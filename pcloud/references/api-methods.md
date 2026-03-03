# pCloud API Methods Reference

Complete reference of all pCloud API methods organized by category. Base URL: `https://api.pcloud.com/` (US) or `https://eapi.pcloud.com/` (EU).

## Table of Contents

- [General](#general)
- [Folder](#folder)
- [File](#file)
- [Auth](#auth)
- [Streaming](#streaming)
- [Archiving](#archiving)
- [Sharing](#sharing)
- [Public Links](#public-links)
- [Thumbnails](#thumbnails)
- [Upload Links](#upload-links)
- [Revisions](#revisions)
- [Trash](#trash)
- [Collection](#collection)
- [OAuth 2.0](#oauth-20)
- [Transfer](#transfer)
- [Newsletter](#newsletter)

---

## General

| Method | Auth | Description |
|--------|------|-------------|
| `getdigest` | No | Get a digest for password hashing (used in digest-based login) |
| `userinfo` | Yes | Get user account information |
| `supportedlanguages` | No | List supported languages |
| `setlanguage` | Yes | Set user's language |
| `feedback` | Yes | Send feedback to pCloud |
| `currentserver` | No | Return the current API server hostname |
| `diff` | Yes | Get event history (changes) since a given `diffid`. Supports long polling with `block=1` to wait for changes |
| `getfilehistory` | Yes | Get modification history of a file. Params: `fileid` |
| `getip` | No | Get caller's IP address |
| `getapiserver` | No | Get the best API server for the connection. Returns `binapi` and `api` hostnames |

---

## Folder

| Method | Auth | Description |
|--------|------|-------------|
| `createfolder` | Yes | Create a folder. Required: `folderid` or `path` (parent) + `name` |
| `createfolderifnotexists` | Yes | Create a folder only if it doesn't exist. Same params as `createfolder` |
| `listfolder` | Yes | List folder contents. Required: `folderid` or `path`. Optional: `recursive=1`, `showdeleted=1`, `nofiles=1`, `noshares=1` |
| `renamefolder` | Yes | Rename/move a folder. Required: `folderid` + `toname` or `tofolderid`/`topath` |
| `deletefolder` | Yes | Delete an empty folder. Required: `folderid` or `path` |
| `deletefolderrecursive` | Yes | Delete a folder and all its contents. Required: `folderid` or `path` |
| `copyfolder` | Yes | Copy a folder. Required: `folderid` + `tofolderid` or `topath`. Optional: `noover=1`, `skipexisting=1`, `copycontentonly=1` |

### listfolder Example

```bash
curl -s -H "Authorization: Bearer TOKEN" "https://api.pcloud.com/listfolder?folderid=0"
```

Response:
```json
{
  "result": 0,
  "metadata": {
    "folderid": 0,
    "name": "/",
    "isfolder": true,
    "contents": [
      { "folderid": 230807, "name": "Documents", "isfolder": true },
      { "fileid": 1723778, "name": "photo.jpg", "isfolder": false, "size": 73269 }
    ]
  }
}
```

---

## File

| Method | Auth | Description |
|--------|------|-------------|
| `uploadfile` | Yes | Upload file(s) via `multipart/form-data`. Params: `folderid`/`path`, `filename`, `nopartial`, `progresshash`, `renameifexists` |
| `uploadprogress` | Yes | Get upload progress. Params: `progresshash` (same value passed to `uploadfile`) |
| `downloadfile` | Yes | Download a file from a URL to pCloud. Params: `url`, `folderid`/`path`. Optional: `progresshash` |
| `downloadfileasync` | Yes | Same as `downloadfile`, runs asynchronously. Returns `progresshash` to track via `uploadprogress` |
| `copyfile` | Yes | Copy a file. Required: `fileid` + `tofolderid`/`topath`. Optional: `toname`, `noover=1` |
| `checksumfile` | Yes | Get checksums of a file. Required: `fileid` or `path`. Returns `sha256`, `sha1`, `md5` |
| `deletefile` | Yes | Delete a file. Required: `fileid` or `path` |
| `renamefile` | Yes | Rename/move a file. Required: `fileid` + `toname` or `tofolderid`/`topath` |
| `stat` | Yes | Get file metadata. Required: `fileid` or `path` |

### uploadfile Example

```bash
curl -X POST "https://api.pcloud.com/uploadfile" \
  -H "Authorization: Bearer TOKEN" \
  -F "folderid=0" \
  -F "renameifexists=1" \
  -F "file=@photo.jpg"
```

Response:
```json
{
  "result": 0,
  "fileids": [1729212],
  "metadata": [{
    "fileid": 1729212,
    "name": "photo.jpg",
    "size": 73269,
    "contenttype": "image/jpeg",
    "category": 1
  }]
}
```

---

## Auth

| Method | Auth | Description |
|--------|------|-------------|
| `register` | No | Register new user. Required: `mail`, `password`, `termsaccepted=yes` |
| `sendverificationemail` | Yes | Send email verification |
| `verifyemail` | No | Verify email with code |
| `changepassword` | Yes | Change password. Required: `oldpassword`, `newpassword` |
| `lostpassword` | No | Request password reset. Required: `mail` |
| `resetpassword` | No | Reset password with token |
| `invite` | Yes | Invite user by email |
| `userinvites` | Yes | List sent invites |
| `logout` | Yes | Invalidate current auth token |
| `listtokens` | Yes | List active auth tokens |
| `deletetoken` | Yes | Delete a specific auth token |
| `sendchangemail` | Yes | Request email change |
| `changemail` | No | Confirm email change with code |
| `senddeactivatemail` | Yes | Request account deactivation |
| `deactivateuser` | No | Confirm account deactivation |

---

## Streaming

| Method | Auth | Description |
|--------|------|-------------|
| `getfilelink` | Yes | Get direct download link. Required: `fileid` or `path`. Returns `hosts[]` + `path` — construct URL as `https://HOSTS[0]/PATH`. Links are temporary. Optional: `forcedownload=1`, `contenttype`, `maxspeed`, `skipfilename` |
| `getvideolink` | Yes | Get transcoded video link. Required: `fileid` + `abitrate` + `vbitrate` + `resolution`. Optional: `fixedbitrate`, `crop` |
| `getvideolinks` | Yes | Get multiple video quality variants. Required: `fileid`. Returns array of links at different resolutions |
| `getaudiolink` | Yes | Get transcoded audio link. Required: `fileid` + `abitrate`. Optional: `forcedownload` |
| `gethlslink` | Yes | Get HLS (HTTP Live Streaming) link for video. Required: `fileid` + `abitrate` + `vbitrate` + `resolution` |
| `gettextfile` | Yes | Get text file content directly. Required: `fileid` or `path`. Optional: `fromencoding`, `toencoding` |

### getfilelink Usage

```bash
curl -s -H "Authorization: Bearer TOKEN" "https://api.pcloud.com/getfilelink?fileid=123"
```
Response:
```json
{ "result": 0, "hosts": ["c456.pcloud.com"], "path": "/cfZkaBZka..." }
```
Download URL: `https://c456.pcloud.com/cfZkaBZka...`

---

## Archiving

| Method | Auth | Description |
|--------|------|-------------|
| `getzip` | Yes | Download files/folders as ZIP. Params: `fileids` (comma-separated) and/or `folderids` |
| `getziplink` | Yes | Get a link to download ZIP. Same params as `getzip` |
| `savezip` | Yes | Create ZIP and save to pCloud. Params: `fileids`/`folderids` + `tofolderid` + `toname`. Optional: `progresshash` |
| `savezipprogress` | Yes | Track `savezip` progress. Params: `progresshash` |
| `extractarchive` | Yes | Extract archive (zip, rar, 7z, tar, gz, bz2) to pCloud. Required: `fileid` + `tofolderid`. Optional: `noover=1`, `progresshash` |
| `extractarchiveprogress` | Yes | Track `extractarchive` progress using `progresshash` |

---

## Sharing

| Method | Auth | Description |
|--------|------|-------------|
| `sharefolder` | Yes | Share a folder with another user. Required: `folderid` + `mail` (email). `permissions`: `view` or `edit` |
| `listshares` | Yes | List all shares (incoming and outgoing). Optional: `norequests=1`, `noincoming=1`, `nooutgoing=1` |
| `sharerequestinfo` | Yes | Get info about a share request. Required: `sharerequestid` |
| `cancelsharerequest` | Yes | Cancel a pending share request. Required: `sharerequestid` |
| `acceptshare` | Yes | Accept a share request. Required: `sharerequestid`. Optional: `folderid` (where to mount), `name` |
| `declineshare` | Yes | Decline a share request. Required: `sharerequestid` |
| `removeshare` | Yes | Remove/leave a share. Required: `shareid` |
| `changeshare` | Yes | Change share permissions. Required: `shareid` + `permissions` (`view`/`edit`) |

---

## Public Links

| Method | Auth | Description |
|--------|------|-------------|
| `getfilepublink` | Yes | Create public link for a file. Required: `fileid` or `path`. Optional: `expire` (datetime), `maxdownloads`, `maxtraffic` |
| `getfolderpublink` | Yes | Create public link for a folder. Required: `folderid` or `path` |
| `gettreepublink` | Yes | Create public tree link (folder + subfolders). Required: `folderid` |
| `showpublink` | No | Get info about a public link. Required: `code` |
| `getpublinkdownload` | No | Get download link from public link. Required: `code`. Optional: `forcedownload`, `contenttype` |
| `copypubfile` | Yes | Copy a public file to your account. Required: `code` + `tofolderid`. Optional: `toname` |
| `listpublinks` | Yes | List all public links you created |
| `listplshort` | Yes | List public links (short format) |
| `deletepublink` | Yes | Delete a public link. Required: `linkid` |
| `changepublink` | Yes | Modify a public link. Required: `linkid`. Optional: `expire`, `maxdownloads`, `maxtraffic`, `shortlink` |
| `getpubthumb` | No | Get thumbnail from public link. Required: `code` + `size` (WxH) |
| `getpubthumblink` | No | Get link to thumbnail. Required: `code` + `size` |
| `getpubthumbslinks` | No | Get multiple thumbnail links. Required: `codes` + `size` |
| `savepubthumb` | Yes | Save public thumbnail to your account. Required: `code` + `size` + `tofolderid` + `toname` |
| `getpubzip` | No | Download public files as ZIP. Required: `code` |
| `getpubziplink` | No | Get link to download public ZIP. Required: `code` |
| `savepubzip` | Yes | Save public ZIP to your account. Required: `code` + `tofolderid` + `toname` |
| `getpubvideolinks` | No | Get video links from public link. Required: `code` |
| `getpubaudiolink` | No | Get audio link from public link. Required: `code` + `abitrate` |
| `getpubtextfile` | No | Get text content from public link. Required: `code` |
| `getcollectionpublink` | Yes | Create public link for a collection. Required: `collectionid` |

---

## Thumbnails

| Method | Auth | Description |
|--------|------|-------------|
| `getthumb` | Yes | Get thumbnail image data directly. Required: `fileid` + `size` (e.g. `120x120`). Optional: `crop=1`, `type` (png/jpeg) |
| `getthumblink` | Yes | Get link to thumbnail. Required: `fileid` + `size` |
| `getthumbslinks` | Yes | Get multiple thumbnail links. Required: `fileids` (comma-separated) + `size` |
| `savethumb` | Yes | Save thumbnail to pCloud. Required: `fileid` + `size` + `tofolderid` + `toname` |

---

## Upload Links

| Method | Auth | Description |
|--------|------|-------------|
| `createuploadlink` | Yes | Create upload link allowing others to upload to your folder. Required: `folderid`. Optional: `comment`, `expire`, `maxspace`, `maxfiles` |
| `listuploadlinks` | Yes | List all upload links |
| `deleteuploadlink` | Yes | Delete an upload link. Required: `uploadlinkid` |
| `changeuploadlink` | Yes | Modify an upload link. Required: `uploadlinkid`. Optional: `comment`, `expire`, `maxspace`, `maxfiles` |
| `showuploadlink` | No | Get info about an upload link. Required: `code` |
| `uploadtolink` | No | Upload file to an upload link. Required: `code` + file via `multipart/form-data` |
| `uploadlinkprogress` | No | Track upload progress on upload link. Required: `progresshash` |
| `copytolink` | No | Copy from URL to upload link. Required: `code` + `url` |

---

## Revisions

| Method | Auth | Description |
|--------|------|-------------|
| `listrevisions` | Yes | List file revisions. Required: `fileid` |
| `revertrevision` | Yes | Revert file to a previous revision. Required: `fileid` + `revisionid` |

---

## Trash

| Method | Auth | Description |
|--------|------|-------------|
| `trash_list` | Yes | List trashed items. Optional: `folderid` (to list within), `nofiles=1`, `nofolders=1` |
| `trash_restore` | Yes | Restore a trashed item. Required: `fileid` or `folderid` |
| `trash_restorepath` | Yes | Restore a trashed item to specific path. Required: `fileid`/`folderid` + `topath` |
| `trash_clear` | Yes | Permanently delete all trashed items (or specific: `fileid`/`folderid`) |

---

## Collection

| Method | Auth | Description |
|--------|------|-------------|
| `collection_list` | Yes | List all collections. Optional: `type` |
| `collection_details` | Yes | Get collection details. Required: `collectionid`. Returns metadata of linked files |
| `collection_create` | Yes | Create a collection. Required: `name`. Optional: `type` |
| `collection_rename` | Yes | Rename a collection. Required: `collectionid` + `name` |
| `collection_delete` | Yes | Delete a collection. Required: `collectionid` |
| `collection_linkfiles` | Yes | Add files to a collection. Required: `collectionid` + `fileids` (comma-separated) |
| `collection_unlinkfiles` | Yes | Remove files from a collection. Required: `collectionid` + `fileids` |
| `collection_move` | Yes | Reorder files within a collection. Required: `collectionid` + `fileid` + `position` |

---

## OAuth 2.0

| Method | Auth | Description |
|--------|------|-------------|
| `authorize` | Web page | OAuth 2.0 authorization page. See SKILL.md for full flow. Params: `client_id`, `response_type` (`code`/`token`), `redirect_uri`. Optional: `state`, `force_reapprove` |
| `oauth2_token` | No | Exchange authorization code for access token (code flow only). Required: `client_id`, `client_secret`, `code`. Returns `access_token`, `token_type`, `userid`, `locationid` |

---

## Transfer

| Method | Auth | Description |
|--------|------|-------------|
| `uploadtransfer` | No | Upload files for transfer (send to email). Uses `multipart/form-data`. Params: `sendermail`, `receivermail`, `message` |
| `uploadtransferprogress` | No | Track transfer upload progress. Params: `progresshash` |

---

## Newsletter

| Method | Auth | Description |
|--------|------|-------------|
| `newsletter_subscribe` | No | Subscribe to newsletter. Required: `mail` |
| `newsletter_check` | No | Check subscription status. Required: `mail` |
| `newsletter_verifyemail` | No | Verify newsletter email. Required: `code` |
| `newsletter_unsubscribe` | No | Unsubscribe (authenticated) |
| `newsletter_unsibscribemail` | No | Unsubscribe via email code |
