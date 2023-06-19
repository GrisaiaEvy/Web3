package ws

import (
	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
	"net/http"
	"singo/util"
)

// 游戏是主入口，可以建table、room、初始化player

type AppContext struct {
	roomList    map[string]*Room
	roomCreator map[Player]*Room // 记录创建人

	userList map[string]*Player
}

// App /**初始化系统上下文
var App = &AppContext{
	roomList: map[string]*Room{},
	userList: map[string]*Player{},
}

// 初始化ws配置
var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

/**
发生在加入房间后，
*/

func OnOpen(c *gin.Context) {
	util.Log().Debug("websocket链接\n")
	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		// 链接建立失败
		return
	}

	p := Player{conn: conn}

	// 获取token，验证并且创建ws玩家对象player
	address := c.Param("address")
	roomId := c.Param("roomId")

	p.Register(address)

	// 加入全局变量中
	p.AttachContext(roomId)

	// 配置ws
	p.WSConfig()

	// 进入持续接收消息状态
	p.ReceivingMsg()

	// 资源释放
	defer func() {
		util.Log().Debug("关闭了websocket链接\n")
		p.DetachContext()
		conn.Close()
	}()
}
