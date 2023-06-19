package ws

import (
	"github.com/google/uuid"
	"time"
)

// 房间，自定义房间可能支持观战功能，因此room包含table

type Room struct {
	roomId     string
	createTime time.Time // 房间创建时间
	createBy   *Player   // 房间创建者
	witnesses  []*Player // 观战人
}

func MakeRoom() *Room {
	room := Room{roomId: uuid.New().String(), createTime: time.Now()}
	return &room
}
