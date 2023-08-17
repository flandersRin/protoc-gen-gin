{{$svrType := .ServiceType}}
{{$svrName := .ServiceName}}
{{$validate := .GenValidate}}
// 这里定义 handler interface
type {{.ServiceType}}HTTPHandler interface {
{{- range .MethodSets}}
    {{.Name}}(context.Context, *{{.Request}}, *{{.Reply}}) error
{{- end}}
}

// Register{{.ServiceType}}HTTPHandler define http router handle by gin.
// 注册路由 handler
func Register{{.ServiceType}}HTTPHandler(g *gin.RouterGroup, srv {{.ServiceType}}HTTPHandler) {
    {{- range .Methods}}
    g.{{.Method}}("{{.Path}}", {{$svrType}}{{.Name}}HTTPHandler(srv))
    {{- end}}
}

// 定义 handler
// 遍历之前解析到所有 rpc 方法信息
{{range .Methods}}
func {{$svrType}}{{.Name}}HTTPHandler(srv {{$svrType}}HTTPHandler) func(c *gin.Context) {
    return func(c *gin.Context) {
        var (
            in  = new({{.Request}})
            out = new({{.Reply}})
            ctx = GetContextFromGinCtx(c)
        )

        if err := c.ShouldBind(in{{.Body}}); err != nil {
            c.AbortWithStatusJSON(400, gin.H{"err": err.Error()})
            return
        }

        // 这里就是最开始提到的判断是否启用 validate
        // 其中这个 api.Validator 接口只有一个方法 Validate() error
        // 所以需要在一个统一的地方定义好引入使用，建议不要在生成的时候写入，因为这个是通用的 interface{}
        {{if $validate -}}
        // check param
        if v, ok := interface{}(in).(api.Validator);ok {
            if err := v.Validate();err != nil {
                c.AbortWithStatusJSON(400, gin.H{"err": err.Error()})
                return
            }
        }
        {{end -}}

        // 执行方法
        err := srv.{{.Name}}(ctx, in, out)
        if err != nil {
            c.AbortWithStatusJSON(500, gin.H{"err": err.Error()})
            return
        }

        c.JSON(200, out)
    }
}
{{end}}

func GetContextFromGinCtx(gin *gin.Context) context.Context {
	return gin.Request.Context()
}