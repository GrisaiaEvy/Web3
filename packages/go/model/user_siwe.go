package model

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type UserSiwe struct {
	gorm.Model
	Nickname  string
	Avater    string
	Address   string
	PublicKey string
}

func (u *UserSiwe) TableName() string {
	return "user_siwe"
}

func (user *UserSiwe) RandomNickName() {
	user.Nickname = "用户昵称#" + uuid.New().String()
}

func GetUserByAddress(address string) (UserSiwe, error) {
	var user UserSiwe
	result := DB.First(&user, "address = ?", address)
	return user, result.Error
}
