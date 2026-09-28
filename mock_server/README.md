# Mock REST API

这个目录使用 `json-server` 提供学习用的项目 REST API，不需要创建完整的
Node.js 后端项目。

## 启动

请先安装 Node.js，然后在本目录运行：

```bash
npx json-server db.json --port 3000
```

启动后可以访问以下接口：

- `GET /projects`
- `POST /projects`
- `PUT /projects/:id`
- `DELETE /projects/:id`

## Flutter 访问地址

Android Emulator 中的 `localhost` 指向模拟器本身，因此 App 默认使用：

```text
http://10.0.2.2:3000
```

Windows 桌面和 Web 通常应访问 `http://localhost:3000`。可以在运行时覆盖统一的
API 地址，不需要修改每个请求：

```bash
flutter run -d windows --dart-define=PROJECT_API_BASE_URL=http://localhost:3000
```

真机需要使用电脑在局域网中的 IP，并确认防火墙允许访问 3000 端口。
