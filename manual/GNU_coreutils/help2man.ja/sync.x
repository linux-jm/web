[名前]
.\"O sync \- Synchronize cached writes to persistent storage
sync \- キャッシュされた書き込みを永続ストレージに同期する
[バグ]
.\"O Persistence guarantees vary per system.
.\"O See the system calls below for more details.
永続性の保証度合いはシステムにより異なります。
詳細は下記のシステムコールを参照。
[説明]
.\" Add any additional description here
[関連項目]
fdatasync(2), fsync(2), sync(2), syncfs(2)
