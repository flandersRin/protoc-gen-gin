# Protoc 自定义插件

## 生成 protoc 插件，自定义业务 gin 代码

```shell
# 生成 protoc 插件
go build -o protoc-gen-gin

# 查看当前 go 安装目录
go env | grep GOPATH
$ GOPATH='/Users/xxx/go'

# 拷贝 go build 可执行文件到 GOPATH
mv ./protoc-gen-gin /Users/xxx/go

# 根据项目定义的 proto 生成 gin 代码
protoc -I . --proto_path=$GOPATH/src:. --go_out=. --gin_out=router=gin:. --go-grpc_out=.  gin_api.proto
```
