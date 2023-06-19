package ws

import "time"

// 牌桌代表一局游戏

type Table struct {
	tableUUID string
	status    string // 未准备、游戏中
	round     int8   // 游戏轮次
	players   map[string]*Player
}

// 牌桌60s后关闭
func (t *Table) shutdown() {
	time.Tick(60 * time.Second)
}

func (t *Table) playCard(player *Player, card string) {
	// 校验出牌规则
	res := check(card)
	if !res {
		judge()
	}
	// 游戏轮次增加
	t.round++
	// 记录日志
	record()
	// 广播发牌给其它玩家
	for _, v := range t.players {
		if v != player {
		}
	}
}

/* http接口 */

func (t Table) MakeTable() {

}
