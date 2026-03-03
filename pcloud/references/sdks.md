# pCloud SDKs Reference

Official SDKs for integrating with the pCloud API across platforms.

## Table of Contents

- [JavaScript](#javascript)
- [PHP](#php)
- [Java](#java)
- [Swift](#swift)
- [C (Binary API)](#c-binary-api)

---

## JavaScript

**GitHub**: https://github.com/pCloud/pcloud-sdk-js

Works in both **browser** and **Node.js** environments.

### Installation

```bash
npm install pcloud-sdk-js
```

### Usage

```javascript
const pCloudSdk = require("pcloud-sdk-js");

// Create client with access token
const client = pCloudSdk.createClient("ACCESS_TOKEN");

// List root folder
client.listfolder(0).then((response) => {
  console.log(response.contents);
});

// Upload file (Node.js)
const fs = require("fs");
client.upload("photo.jpg", 0, {
  onBegin: () => console.log("Upload started"),
  onProgress: (progress) => console.log(`Progress: ${progress.loaded}/${progress.total}`),
  onFinish: (metadata) => console.log("Done:", metadata),
});
```

---

## PHP

**GitHub**: https://github.com/pCloud/pcloud-sdk-php

### Installation

```bash
composer require pcloud/pcloud-php-sdk
```

### Usage

```php
use pCloud\Sdk\App;
use pCloud\Sdk\File;
use pCloud\Sdk\Folder;

// Initialize
$app = new App();
$app->setAccessToken("ACCESS_TOKEN");

// Folder operations
$folder = new Folder($app);
$folderContent = $folder->listFolder(0);

// File operations
$file = new File($app);
$fileMetadata = $file->upload("/local/path/photo.jpg", 0);
$file->download(12345, "/local/download/path/");
```

---

## Java

**GitHub (SDK)**: https://github.com/pCloud/pcloud-sdk-java
**GitHub (Networking)**: https://github.com/pCloud/pcloud-networking-java
**GitHub (Binary API)**: https://github.com/pcloudfs/pclouddoc/tree/master/binapi-java

### SDK Installation (Gradle)

```groovy
implementation 'com.pcloud.sdk:java-core:x.x.x'

// For Android
implementation 'com.pcloud.sdk:android:x.x.x'
```

### Usage

```java
import com.pcloud.sdk.*;

// Create API client
ApiClient apiClient = PCloudSdk.newClientBuilder()
    .authenticator(Authenticators.newOAuthAuthenticator("ACCESS_TOKEN"))
    .create();

// List folder
RemoteFolder folder = apiClient.listFolder(RemoteFolder.ROOT_FOLDER_ID).execute();
for (RemoteEntry entry : folder.children()) {
    System.out.println(entry.name());
}

// Upload file
RemoteFile file = apiClient.createFile(
    RemoteFolder.ROOT_FOLDER_ID,
    "photo.jpg",
    DataSource.create(new File("/path/to/photo.jpg"))
).execute();
```

---

## Swift

**GitHub**: https://github.com/pCloud/pcloud-sdk-swift

For **iOS** and **macOS** applications.

### Installation (CocoaPods)

```ruby
pod 'PCloudSDKSwift'
```

### Installation (SPM)

```swift
.package(url: "https://github.com/pCloud/pcloud-sdk-swift", from: "3.0.0")
```

### Usage

```swift
import PCloudSDKSwift

// Initialize with OAuth token
PCloud.setUp(withAccessToken: "ACCESS_TOKEN")

// List root folder
PCloud.sharedClient.listFolder(0)
    .addCompletionBlock { result in
        switch result {
        case .success(let folder):
            print(folder.contents)
        case .failure(let error):
            print(error)
        }
    }
    .start()

// Upload file
let fileUrl = URL(fileURLWithPath: "/path/to/file")
PCloud.sharedClient.upload(fromFileAt: fileUrl, toFolder: 0, asFileNamed: "file.jpg")
    .addProgressBlock { uploaded, total in
        print("Progress: \(uploaded)/\(total)")
    }
    .addCompletionBlock { result in
        // handle result
    }
    .start()
```

---

## C (Binary API)

**GitHub**: https://github.com/pcloudfs/pclouddoc/tree/master/binapi-c

Low-level C SDK using the pCloud binary protocol for maximum performance.

### Connection Methods

| Method | Signature | Description |
|--------|-----------|-------------|
| `api_connect` | `apisock *api_connect()` | Connect to API server. Returns `NULL` on failure |
| `api_connect_ssl` | `apisock *api_connect_ssl()` | Connect via SSL. Returns `NULL` on failure |
| `api_close` | `void api_close(apisock *sock)` | Close connection |
| `send_command` | `binresult *send_command(apisock *sock, const char *command, ...)` | Send command and get result. Free result with `free()` |
| `send_command_nb` | `binresult *send_command_nb(apisock *sock, const char *command, ...)` | Non-blocking send. Read result later with `get_result()` |
| `send_data_command` | `send_data_command(apisock *sock, const char *command, uint64_t datalen, ...)` | Send command with data payload. Write data with `writeall()`, read result with `get_result()` |
| `get_result` | `binresult *get_result(apisock *sock)` | Read result from non-blocking command |
| `writeall` | `int writeall(apisock *sock, const void *ptr, size_t len)` | Write data to socket. Returns 0=success, -1=error |
| `readall` | `ssize_t readall(apisock *sock, void *ptr, size_t len)` | Read data from socket. Returns bytes read or -1 |

### Parameter Macros

| Macro | Usage | Description |
|-------|-------|-------------|
| `P_STR` | `P_STR("name", "value")` | String parameter |
| `P_LSTR` | `P_LSTR("name", "value", len)` | String with known length (no null-terminator needed) |
| `P_NUM` | `P_NUM("name", uint64_value)` | Numeric parameter |
| `P_BOOL` | `P_BOOL("name", bool_value)` | Boolean parameter |

### Example

```c
#include "pcloudapi.h"

int main() {
    apisock *conn = api_connect_ssl();
    if (!conn) return 1;

    // Login
    binresult *res = send_command(conn, "userinfo",
        P_STR("getauth", "1"),
        P_STR("username", "user@example.com"),
        P_STR("password", "secret")
    );

    // List root folder
    binresult *folder = send_command(conn, "listfolder",
        P_STR("auth", auth_token),
        P_NUM("folderid", 0)
    );

    free(folder);
    free(res);
    api_close(conn);
    return 0;
}
```
