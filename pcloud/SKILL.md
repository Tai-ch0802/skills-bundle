---
name: pcloud
description: Comprehensive pCloud cloud storage API integration and SDK usage. Use when building applications that interact with pCloud for: (1) file upload/download/management, (2) folder operations, (3) OAuth 2.0 authentication, (4) file/folder sharing and public links, (5) media streaming (video/audio/HLS), (6) archiving (zip/extract), (7) thumbnails, (8) trash management, (9) file revisions, (10) collections, (11) upload links, or (12) using any pCloud SDK (JavaScript, PHP, Java, Swift, C).
---

# pCloud API Development Skill

## Overview

pCloud is a cloud storage service exposing a REST-like HTTP JSON API and a binary protocol. Key capabilities:
- **File management** — Upload, download, copy, rename, delete, checksum
- **Folder operations** — Create, list (recursive), rename, delete, copy
- **Sharing** — Share folders with other users (view/edit permissions)
- **Public links** — Generate public download/streaming links for files and folders
- **Media streaming** — Direct file links, video transcoding, audio streaming, HLS
- **Archiving** — Create/extract ZIP archives server-side
- **Thumbnails** — Generate image/video thumbnails server-side
- **Collections** — Organize files into virtual collections
- **Trash** — List, restore, clear deleted items
- **Revisions** — List and revert file revisions
- **Upload links** — Create links allowing others to upload to your account
- **Remote upload** — Download files from URL directly into pCloud

## API Endpoints (Data Centers)

> [!IMPORTANT]
> pCloud operates **two data centers**. Use the correct hostname based on the user's data location.

| Location | API Hostname | OAuth Hostname |
|----------|-------------|----------------|
| United States (locationid=1) | `api.pcloud.com` | `my.pcloud.com` |
| Europe (locationid=2) | `eapi.pcloud.com` | `e.pcloud.com` |

After OAuth authorization, the redirect URL includes `locationid` and `hostname` parameters indicating which API endpoint to use for that user. **Always store and use the correct hostname per user.**

## Authentication

### OAuth 2.0 (Recommended)

Start at: `https://my.pcloud.com/oauth2/authorize` (US) or `https://e.pcloud.com/oauth2/authorize` (EU)

**Two flows:**

1. **Code Flow** (server apps) — Returns `code` via redirect → exchange for `access_token` using `oauth2_token`
   ```
   GET https://my.pcloud.com/oauth2/authorize?
     client_id=APP_ID&
     response_type=code&
     redirect_uri=REDIRECT_URI&
     state=RANDOM
   ```
   Redirect returns: `?code=XXXXX&locationid=1&hostname=api.pcloud.com`
   Then call `oauth2_token` with the code + `client_secret` to get the bearer token.

2. **Token Flow** (client-side/mobile) — Returns `access_token` directly in redirect fragment
   ```
   GET https://my.pcloud.com/oauth2/authorize?
     client_id=APP_ID&
     response_type=token&
     redirect_uri=REDIRECT_URI
   ```
   Redirect returns: `#access_token=XXXXX&token_type=bearer&locationid=1&hostname=api.pcloud.com`

### Using Auth Tokens

Pass the `access_token` as the `auth` parameter in every API call:
```
GET https://api.pcloud.com/listfolder?folderid=0&auth=ACCESS_TOKEN
```

Or use `Authorization: Bearer ACCESS_TOKEN` header.

### Digest Login (Legacy)

1. Call `getdigest` to get a digest
2. Call `userinfo` with `getauth=1&logout=1&username=EMAIL&digest=DIGEST&passworddigest=SHA1(PASSWORD+SHA1(USERNAME_LOWERCASE)+DIGEST)&authexpire=SECONDS`
3. Response contains `auth` token

## HTTP JSON Protocol

### Request Format

All methods accept both `GET` and `POST`. Base URL: `https://api.pcloud.com/METHOD_NAME`

```bash
# GET request
curl -s -H "Authorization: Bearer TOKEN" "https://api.pcloud.com/listfolder?folderid=0"

# POST request
curl -s -X POST "https://api.pcloud.com/listfolder" \
  -H "Authorization: Bearer TOKEN" \
  -d "folderid=0"
```

### Response Format

```json
// Success
{ "result": 0, ... }

// Error
{ "result": 2000, "error": "Log in required." }
```

### File Upload

Use `POST` with `multipart/form-data`. Parameters must come before files:
```bash
curl -X POST "https://api.pcloud.com/uploadfile" \
  -F "auth=TOKEN" \
  -F "folderid=0" \
  -F "file=@/path/to/file.jpg"
```

Multiple files can be uploaded in a single request. Set `renameifexists=1` to avoid overwriting.

## Global Parameters

These optional parameters apply to all methods (omitted from per-method docs):
- `auth` — Authentication token
- `authexpire` — Token expiry in seconds (on login)
- `authinactiveexpire` — Expire after N seconds of inactivity
- `device` — Device identifier string

## Core Concepts

### Identifiers
- **Folders**: `folderid` (int) or `path` (string). Root folder is always `folderid=0`
- **Files**: `fileid` (int) or `path` (string)
- Both `folderid`/`fileid` and `path` are accepted; if both provided, `folderid`/`fileid` takes precedence

### Metadata Structure

Every file/folder returns a metadata object:
```json
{
  "name": "file.jpg",
  "isfolder": false,
  "fileid": 1729212,
  "parentfolderid": 0,
  "size": 73269,
  "contenttype": "image/jpeg",
  "category": 1,
  "created": "Wed, 02 Oct 2013 14:29:11 +0000",
  "modified": "Wed, 02 Oct 2013 14:29:11 +0000",
  "hash": 10681749967730527559,
  "isshared": false,
  "ismine": true,
  "thumb": true,
  "icon": "image"
}
```

**Categories**: 0=uncategorized, 1=image, 2=video, 3=audio, 4=document, 5=archive

**Folder metadata** includes `contents` array when returned by `listfolder`.

**Media metadata** may include: `width`, `height`, `duration`, `fps`, `videocodec`, `audiocodec`, `videobitrate`, `audiobitrate`, `audiosamplerate`, `rotate`.

## Common Workflows

### List folder contents
```bash
curl -s -H "Authorization: Bearer TOKEN" "https://api.pcloud.com/listfolder?folderid=0&recursive=1"
```

### Upload a file
```bash
curl -s -H "Authorization: Bearer TOKEN" -F "folderid=0" -F "file=@photo.jpg" \
  https://api.pcloud.com/uploadfile
```

### Get download link
```bash
curl "https://api.pcloud.com/getfilelink?fileid=123&auth=TOKEN"
# Returns: { "hosts": ["c123.pcloud.com"], "path": "/cfZka..." }
# Download URL: https://c123.pcloud.com/cfZka...
```

### Share a folder
```bash
curl "https://api.pcloud.com/sharefolder?folderid=123&mail=user@example.com&permissions=edit&auth=TOKEN"
```

### Create public link
```bash
curl "https://api.pcloud.com/getfilepublink?fileid=123&auth=TOKEN"
```

## Detailed References

Load these references as needed:

- **All API methods by category**: See [api-methods.md](references/api-methods.md) for complete method reference with parameters and descriptions
- **SDK setup and usage**: See [sdks.md](references/sdks.md) for JavaScript, PHP, Java, Swift, and C SDK details
- **Error codes**: See [error-codes.md](references/error-codes.md) for error code table and troubleshooting
