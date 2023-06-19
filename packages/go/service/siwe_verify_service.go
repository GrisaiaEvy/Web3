package service

import (
	"encoding/json"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/gin-gonic/gin"
	"github.com/spruceid/siwe-go"
	"singo/model"
	"singo/serializer"
)

type SiweMessage struct {
	address   string
	statement string
	domain    string
	uri       string
	version   string
	chainId   int64
}

// 1.注册
// 2.前端使用axios调用接口
// 3.理清楚游戏逻辑

type VerifyParam struct {
	Message   string `form:"message" json:"message" binding:"required"`
	Signature string `form:"signature" json:"signature" binding:"required"`
	Nickname  string
	Username  string
}

func (v *VerifyParam) Verify(c *gin.Context) serializer.Response {
	siweMessage, err := siwe.ParseMessage(v.Message)
	if err != nil {
		return serializer.Response{Code: 500, Msg: "解析为消息失败"}
	}
	publicKey, err := siweMessage.VerifyEIP191(v.Signature)
	if err != nil {
		return serializer.Response{Code: 500, Msg: "验证失败"}
	}
	address := crypto.PubkeyToAddress(*publicKey).String()

	var user model.UserSiwe

	model.DB.First(&user, "address = ?", address)
	if user.ID == 0 {
		publicKeyJson, _ := json.Marshal(publicKey)
		user = model.UserSiwe{PublicKey: string(publicKeyJson), Address: address}
		user.RandomNickName()
		model.DB.Create(&user)
	}
	return serializer.Response{Code: 200, Data: user}
}

func CreateMatch() bool {

	return true
}
