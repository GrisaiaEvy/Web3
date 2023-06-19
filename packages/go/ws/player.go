package ws

import (
	"github.com/gorilla/websocket"
	"log"
	"singo/model"
	"time"
)

const (
	writeWait      = 1 * time.Second
	pongWait       = 60 * time.Second
	pingPeriod     = (pongWait * 9) / 10
	maxMessageSize = 512
)

type Player struct {
	conn     *websocket.Conn
	table    *Table // 一个用户同一时刻只在一个牌桌上
	room     *Room
	address  string
	nickname string
}

func (p *Player) SendMessage(msg string) {

}

// 接收消息
func (p *Player) ReceivingMsg() {
	conn := p.conn
	for {
		_, message, err := conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("error: %v", err)
			}
			break
		}
		log.Printf("Received message: %s", string(message))
		// 处理消息
		//fmt.Println("接收到websocket消息：" + )
	}
}

func (p *Player) WSConfig() {
	p.conn.SetReadLimit(maxMessageSize)
	p.conn.SetReadDeadline(time.Now().Add(pongWait))
	p.conn.SetPongHandler(func(string) error { p.conn.SetReadDeadline(time.Now().Add(pongWait)); return nil })
}

func (p *Player) AttachContext(roomId string) {
	p.EnterRoom(roomId)
	App.userList[p.address] = p
}

func (p *Player) DetachContext() {

}

func (p *Player) EnterRoom(roomId string) *Room {
	room := App.roomList[roomId]
	// 如果房间为空
	if room == nil {
		room = MakeRoom()
		room.createBy = p
		App.roomList[room.roomId] = room
	}
	return room
}

func (p *Player) Register(address string) {
	user, err := model.GetUserByAddress(address)
	if err != nil {
		p.SendMessage("登录验证失败，可能未注册")
		p.conn.Close()
		return
	}
	p.nickname = user.Nickname
	p.address = address
}
