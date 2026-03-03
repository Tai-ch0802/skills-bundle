# pCloud API Error Codes

## Error Response Format

All API errors return a JSON object with `result` (error code) and `error` (human-readable message):

```json
{ "result": 2000, "error": "Log in required." }
```

A `result` of `0` always indicates success.

## Error Code Reference

### General Errors (1000-1xxx)

| Code | Error | Description |
|------|-------|-------------|
| 1000 | Log in required | Authentication needed but not provided |
| 1001 | No full path or name/folderid provided | Missing required folder/file identifier |
| 1002 | No full path or folderid provided | Missing folder path or folderid parameter |
| 1004 | No fileid or path provided | Missing file identifier |
| 1006 | Please provide flags | Required flags parameter missing |
| 1007 | Invalid or closed file descriptor | Bad file descriptor |
| 1008 | Please provide offset | Missing offset parameter |
| 1009 | Please provide length | Missing length parameter |
| 1010 | Please provide count | Missing count parameter |

### Login/Auth Errors (2000-2xxx)

| Code | Error | Description |
|------|-------|-------------|
| 2000 | Log in required | Need to authenticate first |
| 2001 | Invalid file/folder name | Forbidden characters in name |
| 2002 | A component of parent directory does not exist | Path doesn't exist |
| 2003 | Access denied | Insufficient permissions |
| 2004 | File or folder already exists | Name conflict |
| 2005 | Directory does not exist | Target folder not found |
| 2006 | Folder is not empty | Cannot delete non-empty folder (use `deletefolderrecursive`) |
| 2007 | Cannot delete the root folder | Attempted to delete root |
| 2008 | User is over quota | Storage limit exceeded |
| 2009 | File not found | File doesn't exist |
| 2010 | Invalid path | Malformed path string |
| 2023 | You are trying to place folder into itself | Circular folder operation |

### Authentication Errors

| Code | Error | Description |
|------|-------|-------------|
| 2011 | Provided 'access_token' has expired | OAuth token expired |
| 2012 | Invalid access_token | Token is invalid or revoked |
| 2013 | Invalid authexpire value | Bad token expiry value |
| 2014 | Invalid authinactiveexpire value | Bad inactive expiry value |
| 2015 | Too many login attempts | Rate limited — wait before retrying |
| 2016 | Invalid email or password | Login credentials wrong |

### Sharing Errors (4000-4xxx)

| Code | Error | Description |
|------|-------|-------------|
| 4000 | Share not found | Share ID doesn't exist |
| 4001 | Cannot share root folder | Root folder sharing not allowed |
| 4002 | Cannot share with yourself | Self-sharing not allowed |
| 4003 | No share permissions specified | Missing `permissions` parameter |
| 4004 | Already shared with this user | Duplicate share |
| 4005 | There is an already pending request | Pending request exists for this share |

### Public Link Errors

| Code | Error | Description |
|------|-------|-------------|
| 7002 | Invalid link code | Public link code not found |
| 7003 | Link has expired | Public link past expiry date |
| 7004 | Link is over traffic quota | Downloads exceeded `maxtraffic` |
| 7005 | Link is over download quota | Downloads exceeded `maxdownloads` |

### Upload Link Errors (5000-5xxx)

| Code | Error | Description |
|------|-------|-------------|
| 5000 | Upload link not found | Upload link ID doesn't exist |
| 5001 | Upload link has expired | Past expiry date |
| 5002 | Upload link is over space quota | Files exceed `maxspace` |
| 5003 | Upload link is over file count quota | Files exceed `maxfiles` |

### Archiving Errors

| Code | Error | Description |
|------|-------|-------------|
| 6000 | Unsupported archive format | Archive type not supported for extraction |
| 6001 | Archive is corrupt | Cannot read archive contents |

## Troubleshooting

### Common Issues

1. **Error 2000 on every request**: Ensure `auth` parameter is included. Check `locationid` — using US endpoint with EU user or vice versa.

2. **Error 2008 (over quota)**: User has exceeded storage. Check `userinfo` for `quota` and `usedquota`.

3. **Error 2015 (too many login attempts)**: Implement exponential backoff. Consider using OAuth tokens instead of repeated logins.

4. **Error 2011/2012 (token issues)**: OAuth access tokens from pCloud do not expire by default unless the user revokes them. If using digest login, check `authexpire`.

5. **File uploads returning errors**: Ensure `Content-Type: multipart/form-data`, parameters come before file data, and file size doesn't exceed quota.

6. **Wrong data center**: If `locationid=2` (Europe), use `eapi.pcloud.com` — not `api.pcloud.com`. Mixing endpoints causes auth failures.
