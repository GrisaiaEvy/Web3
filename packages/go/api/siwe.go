package api

import (
	"github.com/gin-gonic/gin"
	"github.com/spruceid/siwe-go"
	"singo/serializer"
	"singo/service"
)

func Nonce(c *gin.Context) {
	nonce := siwe.GenerateNonce()
	c.JSON(200, serializer.Response{Code: 200, Data: nonce})
}

// 有账号登录，无账户自动注册，使用签名告知
func Verify(c *gin.Context) {
	var param service.VerifyParam
	if err := c.ShouldBind(&param); err == nil {
		c.JSON(200, param.Verify(c))
	} else {
		c.JSON(200, ErrorResponse(err))
	}
}

func CreateMatch() {

}
