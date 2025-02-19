local bit = require("bit")  --引入必要的库
local bor = bit.bor  --位或运算函数
local band = bit.band  --位于运算函数
local bnot = bit.bnot  --位非运算函数
local E = require("entity_db")  --引入实体数据库模块
local i18n = require("i18n")  --引入国际化模块

require("constants")  --引入常量定义模块

local anchor_y = 0  --定义y轴锚点
local image_x = 0  --定义图像x
local image_y, tt = nil  --定义图像y坐标和tt变量（未初始化）  lua文件中nil相当于None
local scripts = require("game_scripts")  --引入游戏脚本模块

require("templates")  --引入模块定义模块

local IS_PHONE = KR_TARGET == "phone" --判断目标平台是否为手机
local IS_CONSOLE = KR_TARGET == "console"  --判断目标平台是否为游戏主机 
--"console:vt.安慰，n.控制台，仪表盘；电视机（或收音机）柜；风琴的操作部分；（带装饰的）支架，支托"（来源于有道翻译）
--"console game:游戏机"

local function v(v1, v2)  --创建一个二维向量的函数
	return {
		x = v1,
		y = v2
	}
end

local function vv(v1)  --定义创建相同x和y值的二维向量函数
	return {
		x = v1,
		y = v1
	}
end

local function r(x, y, w, h)  --创建一个矩形的函数
	return {
		pos = v(x, y),  --返回位置  "pos"即"position"位置
		size = v(w, h)  --返回大小  "size"即"大小”
	}
end

local function fts(v)  --定义帧数转为秒数的函数
	return v / FPS  --将帧数除以每秒帧数（帧速率）即可得到时间
end

local function adx(v)  --定义x轴锚点调整函数
	return v - anchor_x * image_x  --返回调整好的x坐标
end

local function ady(v)  --定义y轴锚点调整函数
	return v - anchor_y * image_y  --返回调整好的y轴坐标
end

local function np(pi, spi, ni)  --创建带方向和索引的对象的函数
	return {
		dir = 1,
		pi = pi,  --返回带有方向和索引的表
		spi = spi,
		ni = ni
	}
end

local function d2r(d)  --定义角度转为弧度的函数
	return d * math.pi / 180  --将角度乘π然后除以180
end

local function RT(name, ref)  --定义注册新模板的函数
	return E:register_t(name, ref)  --调用实体数据库的注册模板的方法
end

local function AC(tpl, ...)  --定义向模板添加组件的函数
	return E:add_comps(tpl, ...)  --调用实体数据库的添加组件的方法
end

local function CC(comp_name)  --定义克隆组件的函数
	return E:clone_c(comp_name)  --调用实体数据库克隆组件的函数
end

tt = E:register_t("pop_crit", "pop")  --注册暴击弹出效果 "crit:n.暴击；（核反应堆）保持一种自身支持的链式反应；评判"
tt.render.sprites[1].name = "pop_0003"
tt = E:register_t("pop_headshot", "pop")  --注册爆头弹出效果
tt.render.sprites[1].name = "pop_0007"
tt = RT("ps_shotgun_musketeer", "particle_system")  --注册火枪手霰弹枪粒子系统，指定模板为particle_system
--"musketeer:n.火枪手" "shotgun:n.霰弹枪，猎枪，副驾驶"
--关于shotgun为什么会有“副驾驶”的意思：似乎是因为有的美国人会在副驾驶放枪
tt.particle_system.animated = true  --"animated:adj.活跃度，生机勃勃的；动画（片）的，栩栩如生的"
tt.particle_system.emission_rate = 20  --设置粒子系统的发射速率为20
tt.particle_system.loop = false  --不循环  "loop:n.环形，环状物，回线，循环"
tt.particle_system.name = "ps_shotgun_musketeer"
tt.particle_system.particle_lifetime = {  --设计粒子系统的生命周期为13帧
	fts(13),  --将帧数转化为秒数
	fts(13)
}
tt.particle_system.track_rotation = true  --设置粒子系统跟踪旋转 "track:v.追踪" "rotation:n.旋转"

tt = RT("ps_bolt_sorcerer", "particle_system")  --注册法师闪电粒子系统 
--"bolt:n闪电，霹雳；（门或窗的）金属插销；螺栓；迅速逃跑，溜走；（布的）一匹；枪栓，枪机；弩箭；（纸等的）卷边" 
--"sorcerer:n魔术师，男巫师" 女巫：witch,sorceress
tt.particle_system.alphas = {  --设置粒子的透明度变化，从255（不透明）到0（完全透明）
	255,
	0
}
tt.particle_system.animated = false  --设置粒子不使用动画
tt.particle_system.emit_area_spread = v(6, 6)  --设置粒子发射区域的扩散范围为6×6
tt.particle_system.emission_rate = 60  --
tt.particle_system.name = "sorcererbolt_particle"
tt.particle_system.particle_lifetime = {
	fts(2),
	fts(5)
}
tt.particle_system.rotation_spread = math.pi  --设置扩算范围为180°
tt.particle_system.scale_var = {  --设置粒子的缩放变化范围
	0.8,
	0.6
}
--scale:规模，范围；等级，级别；刻度，标度；秤；比例，比例尺；音阶；鳞，鳞片；水垢
tt.particle_system.scales_x = {  --设置在x轴上的缩放变化
	1,
	0.3
}
tt.particle_system.scales_y = {  --设置在y轴上的缩放变化
	1,
	0.3
}

tt = RT("ps_tesla_overcharge", "particle_system")  --注册特斯拉过载粒子系统
tt.particle_system.name = "decal_tesla_overcharge"
tt.particle_system.animated = true
tt.particle_system.particle_lifetime = {
	0.7,
	1
}
tt.particle_system.alphas = {
	0,
	255,
	255,
	0
}
tt.particle_system.scales_x = {
	1,
	0.45
}
tt.particle_system.scales_y = {
	1,
	0.45
}
tt.particle_system.scale_same_aspect = true --设置x周和y轴保持相同的缩放比例
tt.particle_system.scale_var = {
	0.5,
	1.5
}
tt.particle_system.emit_spread = 2 * math.pi
tt.particle_system.emit_duration = fts(7)
tt.particle_system.emit_rotation = 0
tt.particle_system.emit_speed = {
	120,
	120
}
tt.particle_system.emission_rate = 90
tt.particle_system.source_lifetime = 2
tt.particle_system.z = Z_OBJECTS  --设置粒子系统的z周位置（用于层级渲染）
tt = E:register_t("ps_arrow_multishot_hero_alleria") --注册英雄alleria的多重箭矢粒子系统

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "hero_archer_arrow_particle"
tt.particle_system.animated = false
tt.particle_system.alphas = {
	255,
	0
}
tt.particle_system.particle_lifetime = {
	0.1,
	0.1
}
tt.particle_system.emission_rate = 30
tt.particle_system.track_rotation = true
tt.particle_system.z = Z_BULLETS
tt = E:register_t("ps_flare_flareon", "particle_system")
tt.particle_system.alphas = {
	255,
	0
}
tt.particle_system.animated = false
tt.particle_system.emission_rate = 40
tt.particle_system.emit_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "Stage9_lavaShotParticle"
tt.particle_system.particle_lifetime = {
	0.35,
	0.7
}
tt.particle_system.scale_same_aspect = true
tt.particle_system.scale_var = {
	0.6,
	0.8
}
tt.particle_system.scales_x = {
	0.8,
	1.6
}
tt.particle_system.scales_y = {
	0.8,
	1.6
}
tt.particle_system.emit_rotation_spread = math.pi
tt = RT("ps_veznan_soul", "particle_system")
tt.particle_system.alphas = {
	255,
	0
}
tt.particle_system.animated = false
tt.particle_system.emission_rate = 60
tt.particle_system.emission_spread = v(6, 6)
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.emit_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "boss_veznan_soul_particle"
tt.particle_system.particle_lifetime = {
	fts(4),
	fts(8)
}
tt.particle_system.scale_same_aspect = true
tt.particle_system.scale_var = {
	0.8,
	1.2
}
tt.particle_system.scales_x = {
	1,
	0.3
}
tt.particle_system.scales_y = {
	1,
	0.3
}
tt = RT("ps_hacksaw_sawblade")

AC(tt, "pos", "particle_system")

tt.particle_system.alphas = {
	255,
	200,
	0,
	0
}
tt.particle_system.animated = true
tt.particle_system.emission_rate = 120
tt.particle_system.emit_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "ps_hacksaw_sawblade"
tt.particle_system.particle_lifetime = {
	fts(12),
	fts(12)
}
tt.particle_system.scales_x = {
	1,
	0.5
}
tt.particle_system.scales_y = {
	1.5,
	0.5
}
tt = RT("ps_elora_run")

AC(tt, "pos", "particle_system")

tt.particle_system.alphas = {
	255,
	0
}
tt.particle_system.animated = true
tt.particle_system.emission_rate = 10
tt.particle_system.loop = false
tt.particle_system.z = Z_DECALS + 1
tt.particle_system.name = "ps_hero_elora_run"
tt.particle_system.particle_lifetime = {
	0.8,
	1
}
tt = RT("ps_hero_ignus_idle", "particle_system")
tt.particle_system.name = "ps_hero_ignus_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {
	0.5,
	0.5
}
tt.particle_system.alphas = {
	255,
	255
}
tt.particle_system.emit_duration = nil
tt.particle_system.emit_direction = d2r(90)
tt.particle_system.emit_speed = {
	30,
	30
}
tt.particle_system.emission_rate = 2.5
tt.particle_system.source_lifetime = nil
tt.particle_system.z = Z_OBJECTS
tt = RT("ps_ignus_run")

AC(tt, "pos", "particle_system")

tt.particle_system.alphas = {
	255,
	200,
	0
}
tt.particle_system.anchor = v(0.5, 0.1)
tt.particle_system.animated = true
tt.particle_system.emission_rate = 10
tt.particle_system.loop = false
tt.particle_system.z = Z_DECALS + 1
tt.particle_system.name = "ps_hero_ignus_run"
tt.particle_system.particle_lifetime = {
	0.6,
	0.8
}
tt = RT("ps_hero_ignus_smoke", "ps_power_fireball")
tt.particle_system.scales_x = {
	2,
	3
}
tt.particle_system.scales_y = {
	2,
	3
}
tt.particle_system.emission_rate = 30
tt.particle_system.emit_offset = v(0, 17)
tt.particle_system.name = "ps_hero_ignus_smoke"
tt.particle_system.sort_y_offset = -16
tt.particle_system.z = Z_OBJECTS
tt = RT("ps_stage_snow")

AC(tt, "pos", "particle_system")

tt.pos = v(512, 768)
tt.particle_system.alphas = {
	255,
	255,
	255,
	0
}
tt.particle_system.emission_rate = 8
tt.particle_system.emit_area_spread = v(1200, 10)
tt.particle_system.emit_direction = 3 * math.pi / 2
tt.particle_system.emit_speed = {
	30,
	40
}
tt.particle_system.emit_spread = math.pi / 8
tt.particle_system.particle_lifetime = {
	20,
	30
}
tt.particle_system.scale_var = {
	0.4,
	0.7
}
tt.particle_system.ts_offset = -20
tt.particle_system.z = Z_OBJECTS_SKY
tt.particle_system.name = "Copo"
tt = RT("fx_teleport_arcane", "fx")
tt.render.sprites[1].anchor.y = 0.5
tt.render.sprites[1].prefix = "fx_teleport_arcane"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}
tt = RT("fx_explosion_shrapnel", "fx")
tt.render.sprites[1].anchor.y = 0.2
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[1].prefix = "explosion"
tt.render.sprites[1].name = "shrapnel"
tt = RT("fx_bolt_sorcerer_hit", "fx")
tt.render.sprites[1].prefix = "bolt_sorcerer"
tt.render.sprites[1].name = "hit"
tt = RT("fx_mod_polymorph_sorcerer_small", "fx")
tt.render.sprites[1].name = "fx_mod_polymorph_sorcerer_small"
tt.render.sprites[1].anchor.y = 0.5
tt = RT("fx_mod_polymorph_sorcerer_big", "fx_mod_polymorph_sorcerer_small")
tt.render.sprites[1].name = "fx_mod_polymorph_sorcerer_big"
tt = RT("fx_hacksaw_sawblade_hit", "fx")
tt.render.sprites[1].prefix = "fx_hacksaw_sawblade"
tt.render.sprites[1].name = "hit"
tt = RT("fx_hero_thor_thunderclap_disipate", "fx")
tt.render.sprites[1].name = "fx_hero_thor_thunderclap_disipate"
tt.render.sprites[1].anchor = v(0.5, 0.15)
tt.render.sprites[1].z = Z_EFFECTS
tt = RT("fx_bolt_elora_hit", "fx")
tt.render.sprites[1].prefix = "fx_bolt_elora"
tt.render.sprites[1].name = "hit"
tt = RT("fx_bolt_magnus_hit", "fx")
tt.render.sprites[1].name = "bolt_magnus_hit"
tt = E:register_t("fx_ignus_burn", "fx")
tt.render.sprites[1].prefix = "fx_burn"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}
tt = RT("fx_juggernaut_smoke", "fx")
tt.render.sprites[1].name = "fx_juggernaut_smoke"
tt.render.sprites[1].anchor.y = 0.27
tt = RT("fx_jt_tower_click", "fx")
tt.render.sprites[1].name = "fx_jt_tower_click"
tt.render.sprites[1].anchor.y = 0.3
tt = RT("fx_moloch_ring", "fx")
tt.render.sprites[1].name = "fx_moloch_ring"
tt.render.sprites[1].z = Z_DECALS
tt = RT("fx_moloch_rocks", "fx")
tt.render.sprites[1].name = "fx_moloch_rocks"
tt.render.sprites[1].anchor.y = 0.24242424242424243
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("fx_myconid_spores", "fx")
tt.render.sprites[1].name = "fx_myconid_spores"
tt.render.sprites[1].anchor.y = 0.8
tt = RT("fx_blackburn_smash", "fx")
tt.render.sprites[1].name = "fx_blackburn_smash"
tt.render.sprites[1].anchor.y = 0.1588785046728972
tt = RT("fx_veznan_demon_fire", "fx")
tt.render.sprites[1].name = "fx_veznan_demon_fire"
tt = E:register_t("fx_explosion_rotten_shot", "fx")
tt.render.sprites[1].name = "explosion_rotten_shot"
tt.render.sprites[1].anchor = v(0.5, 0.33783783783783783)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -2
tt = E:register_t("fx_explosion_flareon_flare", "fx")
tt.render.sprites[1].name = "explosion_flare_flareon"
tt.render.sprites[1].anchor = v(0.5, 0.25)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -2
tt = RT("fx_bolt_necromancer_hit", "fx")
tt.render.sprites[1].prefix = "bolt_necromancer"
tt.render.sprites[1].name = "hit"
tt = RT("fx_demon_portal_out", "fx")
tt.render.sprites[1].prefix = "fx_demon_portal_out"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {
	"small",
	"big"
}
tt = RT("fx_bolt_witch_hit", "fx")
tt.render.sprites[1].name = "fx_bolt_witch_hit"
tt = E:register_t("fx_hobgoblin_ground_hit", "fx")
tt.render.sprites[1].name = "fx_hobgoblin_ground_hit"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].draw_order = 2
tt = RT("decal_paladin_holystrike", "decal_timed")
tt.render.sprites[1].name = "decal_paladin_holystrike"
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_malik_ring", "decal_timed")
tt.render.sprites[1].name = "decal_malik_ring"
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_malik_earthquake", "decal_bomb_crater")
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_malik_earthquake"
tt.render.sprites[2].hide_after_runs = 1
tt.render.sprites[2].anchor.y = 0.24
tt = E:register_t("decal_oni_torment_sword", "decal_scripted")
tt.render.sprites[1].prefix = "decal_oni_torment_sword_1"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].anchor.y = 0.16666666666666666
tt.main_script.update = scripts.decal_oni_torment_sword.update
tt.duration = 0.5
tt.delay = 0.01
tt.sword_names = {
	"decal_oni_torment_sword_1",
	"decal_oni_torment_sword_2",
	"decal_oni_torment_sword_3",
	"decal_oni_torment_sword_1"
}
tt = RT("magnus_arcane_rain_controller", "decal_scripted")

AC(tt, "tween")

tt.main_script.update = scripts.magnus_arcane_rain_controller.update
tt.duration = nil
tt.count = nil
tt.spawn_time = fts(6)
tt.initial_angle = d2r(0)
tt.angle_increment = d2r(70)
tt.entity = "magnus_arcane_rain"
tt.decal = "decal_magnus_arcane_rain"
tt.render.sprites[1].name = "hero_mage_rain_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.5,
		255
	}
}
tt.tween.remove = false
tt.tween.disabled = true
tt = E:register_t("magnus_arcane_rain")

AC(tt, "render", "main_script", "pos")

tt.damage_type = DAMAGE_TRUE
tt.damage_radius = 40
tt.damage_min = 20
tt.damage_max = 20
tt.hit_time = fts(10)
tt.damage_flags = F_AREA
tt.main_script.update = scripts.magnus_arcane_rain.update
tt.render.sprites[1].prefix = "magnus_arcane_rain"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0.5, 0.07)
tt.sound = "HeroMageRainDrop"
tt = RT("denas_cursing", "decal_scripted")
tt.render.sprites[1].name = "hero_denas_cursing"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_OBJECTS
tt.duration = fts(36)
tt.offset = v(0, 25)
tt.main_script.update = scripts.denas_cursing.update
tt = RT("denas_catapult_controller", "decal_scripted")

AC(tt, "tween", "sound_events")

tt.count = nil
tt.bullet = "denas_catapult_rock"
tt.main_script.update = scripts.denas_catapult_controller.update
tt.initial_angle = d2r(0)
tt.initial_delay = 0.25
tt.rock_delay = {
	fts(2),
	fts(8)
}
tt.angle_increment = d2r(60)
tt.rock_offset = v(90, 100)
tt.exit_time = 0.5 + fts(45)
tt.render.sprites[1].name = "hero_king_catapultDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.2,
		255
	}
}
tt.tween.remove = false
tt.sound_events.shoot = "BombShootSound"
tt = RT("denas_buffing_circle", "decal_timed")

AC(tt, "tween")

tt.render.sprites[1].name = "hero_king_glow"
tt.render.sprites[1].anchor = v(0.5, 0.26)
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {
	{
		0,
		25.5
	},
	{
		0.33,
		255
	},
	{
		1,
		0
	}
}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		v(0.7, 0.7)
	},
	{
		1,
		v(1.8, 1.8)
	}
}
tt.tween.remove = true
tt = RT("decal_ignus_flaming", "decal_timed")
tt.render.sprites[1].name = "decal_ignus_flaming"
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_ingvar_attack", "decal_tween")
tt.render.sprites[1].name = "hero_viking_axeDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {
	{
		0,
		200
	},
	{
		1,
		200
	},
	{
		1.5,
		0
	}
}
tt = RT("decal_jt_ground_hit", "decal_timed")
tt.render.sprites[1].name = "decal_jt_ground_hit"
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_jt_tap", "decal_loop")
tt.render.sprites[1].random_ts = fts(7)
tt.render.sprites[1].name = "decal_jt_tap"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y = -40
tt.render.sprites[1].offset = v(20, 40)
tt = RT("decal_blackburn_smash_ground", "decal_timed")
tt.render.sprites[1].name = "fx_blackburn_smash_ground"
tt.render.sprites[1].z = Z_DECALS
tt = RT("veznan_portal", "decal_scripted")

AC(tt, "editor")

tt.render.sprites[1].prefix = "veznan_portal"
tt.render.sprites[1].z = Z_DECALS
tt.fx_out = "fx_demon_portal_out"
tt.main_script.update = scripts.veznan_portal.update
tt.out_nodes = nil
tt.spawn_groups = {
    {
        {
            0.5,
            {
                {
                    16,  -- 原来是4
                    28,  -- 原来是7
                    "enemy_demon"
                }
            }
        },
        {
            0.8,
            {
                {
                    12,  -- 原来是3
                    12,  -- 原来是3
                    "enemy_demon_wolf"
                }
            }
        },
        {
            1,
            {
                {
                    20,  -- 原来是5
                    20,  -- 原来是5
                    "enemy_demon"
                },
                {
                    4,   -- 原来是1
                    4,   -- 原来是1
                    "enemy_demon_mage"
                }
            }
        }
    },
    {
        {
            0.5,
            {
                {
                    8,   -- 原来是2
                    20,  -- 原来是5
                    "enemy_demon"
                }
            }
        },
        {
            0.8,
            {
                {
                    8,   -- 原来是2
                    8,   -- 原来是2
                    "enemy_demon_wolf"
                }
            }
        },
        {
            1,
            {
                {
                    12,  -- 原来是3
                    12,  -- 原来是3
                    "enemy_demon"
                }
            }
        }
    },
    {
        {
            1,
            {
                {
                    12,  -- 原来是3
                    12,  -- 原来是3
                    "enemy_demon"
                }
            }
        }
    }
}
tt.portal_idx = 1
tt.spawn_interval = fts(30)
tt.pi = 1
tt = E:register_t("decal_s12_shoutbox", "decal_tween")

E:add_comps(tt, "texts")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "boss_veznan_taunts_love_0001"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[2].offset = v(-3, 6)
tt.texts.list[1].text = "Hello world"
tt.texts.list[1].size = v(164, 70)
tt.texts.list[1].font_name = "taunts"
tt.texts.list[1].font_size = 24
tt.texts.list[1].color = {
	233,
	189,
	255
}
tt.texts.list[1].line_height = i18n:cjk(1, 1)
tt.texts.list[1].sprite_id = 2
tt.texts.list[1].fit_height = true
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.25,
		255
	},
	{
		"this.duration-0.25",
		255
	},
	{
		"this.duration",
		0
	}
}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].name = "scale"
tt.tween.props[3].keys = {
	{
		0,
		v(1.01, 1.01)
	},
	{
		0.4,
		v(0.99, 0.99)
	},
	{
		0.8,
		v(1.01, 1.01)
	}
}
tt.tween.props[3].sprite_id = 1
tt.tween.props[3].loop = true
tt.tween.props[4] = table.deepclone(tt.tween.props[3])
tt.tween.props[4].sprite_id = 2
tt.tween.remove = true
tt = RT("decal_veznan_strike", "decal_timed")
tt.render.sprites[1].name = "decal_veznan_strike"
tt.render.sprites[1].z = Z_DECALS
tt = RT("veznan_soul", "decal_scripted")
tt.angle_variation = d2r(5)
tt.duration = 8
tt.main_script.update = scripts.veznan_soul.update
tt.max_angle = d2r(70)
tt.min_angle = d2r(-70)
tt.particles_name = "ps_veznan_soul"
tt.render.sprites[1].name = "decal_veznan_soul"
tt.render.sprites[1].z = Z_EFFECTS
tt.speed = {
	6 * FPS,
	15 * FPS
}
tt = RT("decal_eb_veznan_white_circle", "decal_tween")
tt.render.sprites[1].name = "decal_veznan_white_circle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {
	{
		0,
		vv(1)
	},
	{
		fts(65),
		vv(1)
	},
	{
		fts(65) + 0.5,
		vv(20)
	},
	{
		fts(65) + 4.5,
		vv(20)
	}
}
tt = RT("decal_hobgoblin_ground_hit", "decal_tween")
tt.tween.props[1].keys = {
	{
		1,
		255
	},
	{
		2.5,
		0
	}
}
tt.render.sprites[1].name = "hobgoblin_decal"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].animated = false
tt = RT("tower_holder")

AC(tt, "tower", "tower_holder", "pos", "render", "ui", "editor", "editor_script")

tt.ui.click_rect = r(-40, -12, 80, 46)
tt.ui.has_nav_mesh = true
tt.tower.level = 1
tt.tower.type = "holder"
tt.tower.can_be_mod = false
tt.tower_holder.preview_ids = {
	archer = 2,
	engineer = 5,
	barrack = 3,
	mage = 4
}
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "build_terrain_%04i"
tt.render.sprites[1].offset = v(0, 17)
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "tower_preview_archer"
tt.render.sprites[2].animated = false
tt.render.sprites[2].hidden = true
tt.render.sprites[2].offset = v(0, 37)
tt.render.sprites[2].alpha = 180
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].name = "tower_preview_barrack"
tt.render.sprites[3].offset = v(0, 38)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[4].name = "tower_preview_mage"
tt.render.sprites[4].offset = v(0, 30)
tt.render.sprites[5] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[5].name = "tower_preview_artillery"
tt.render.sprites[5].offset = v(0, 41)
tt.editor.props = {
	{
		"tower.terrain_style",
		PT_NUMBER
	},
	{
		"tower.default_rally_pos",
		PT_COORDS
	},
	{
		"tower.holder_id",
		PT_STRING
	},
	{
		"ui.nav_mesh_id",
		PT_STRING
	},
	{
		"editor.game_mode",
		PT_NUMBER
	}
}
tt.editor_script.insert = scripts.editor_tower.insert
tt.editor_script.remove = scripts.editor_tower.remove
tt = RT("tower_holder_grass", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_GRASS
tt.render.sprites[1].name = "build_terrain_0001"
tt = RT("tower_holder_snow", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_SNOW
tt.render.sprites[1].name = "build_terrain_0002"
tt = RT("tower_holder_wasteland", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_WASTELAND
tt.render.sprites[1].name = "build_terrain_0003"
tt = RT("tower_holder_blackburn", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_BLACKBURN
tt.render.sprites[1].name = "build_terrain_0008"
tt = RT("tower_build_archer", "tower_build")
tt.build_name = "tower_archer_1"
tt.render.sprites[2].name = "tower_constructing_0004"
tt.render.sprites[2].offset = v(0, 39)
tt = RT("tower_build_barrack", "tower_build_archer")
tt.build_name = "tower_barrack_1"
tt.render.sprites[2].name = "tower_constructing_0002"
tt.render.sprites[2].offset = v(0, 40)
tt = RT("tower_build_mage", "tower_build_archer")
tt.build_name = "tower_mage_1"
tt.render.sprites[2].name = "tower_constructing_0003"
tt.render.sprites[2].offset = v(0, 31)
tt = RT("tower_build_engineer", "tower_build_archer")
tt.build_name = "tower_engineer_1"
tt.render.sprites[2].name = "tower_constructing_0001"
tt.render.sprites[2].offset = v(0, 41)
tt = RT("tower_mage_1", "tower")

AC(tt, "attacks")

tt.tower.type = "mage"
tt.tower.level = 1
tt.tower.price = 100
tt.info.portrait = IS_PHONE and "portraits_towers_0003" or "info_portraits_towers_0010"
tt.info.enc_icon = 3
tt.info.fn = scripts.tower_mage.get_info
tt.main_script.insert = scripts.tower_mage.insert
tt.main_script.update = scripts.tower_mage.update
tt.attacks.range = 140
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet = "bolt_1"
tt.attacks.list[1].cooldown = 1.5
tt.attacks.list[1].shoot_time = fts(8)
tt.attacks.list[1].bullet_start_offset = {
	v(8, 66),
	v(-5, 62)
}
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_mage_%04i"
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "towermagelvl1"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].offset = v(0, 30)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "shootermage"
tt.render.sprites[3].name = "idleDown"
tt.render.sprites[3].angles = {
	idle = {
		"idleUp",
		"idleDown"
	},
	shoot = {
		"shootingUp",
		"shootingDown"
	}
}
tt.render.sprites[3].offset = v(1, 57)
tt.render.sid_tower = 2
tt.render.sid_shooter = 3
tt.sound_events.insert = "MageTaunt"
tt = RT("tower_mage_2", "tower_mage_1")
tt.info.enc_icon = 7
tt.tower.level = 2
tt.tower.price = 160
tt.attacks.range = 160
tt.attacks.list[1].bullet = "bolt_2"
tt.attacks.list[1].bullet_start_offset = {
	v(8, 66),
	v(-5, 64)
}
tt.render.sprites[2].prefix = "towermagelvl2"
tt.render.sprites[3].offset = v(1, 57)
tt = RT("tower_mage_3", "tower_mage_1")
tt.info.enc_icon = 11
tt.tower.level = 3
tt.tower.price = 240
tt.attacks.range = 180
tt.attacks.list[1].bullet = "bolt_3"
tt.attacks.list[1].bullet_start_offset = {
	v(8, 70),
	v(-5, 69)
}
tt.render.sprites[2].prefix = "towermagelvl3"
tt.render.sprites[3].offset = v(1, 62)
tt = RT("tower_engineer_1", "tower")

AC(tt, "attacks")

tt.tower.type = "engineer"
tt.tower.level = 1
tt.tower.price = 125
tt.info.portrait = IS_PHONE and "portraits_towers_0004" or "info_portraits_towers_0003"
tt.info.enc_icon = 4
tt.main_script.insert = scripts.tower_engineer.insert
tt.main_script.update = scripts.tower_engineer.update
tt.attacks.range = 160
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].bullet = "bomb"
tt.attacks.list[1].cooldown = 3
tt.attacks.list[1].shoot_time = fts(12)
tt.attacks.list[1].vis_bans = bor(F_FLYING)
tt.attacks.list[1].bullet_start_offset = v(0, 50)
tt.attacks.list[1].node_prediction = true
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_artillery_%04i"
tt.render.sprites[1].offset = v(0, 15)

for i = 2, 8 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "towerengineerlvl1_layer" .. i - 1
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].offset = v(0, 41)
end

tt.sound_events.insert = "EngineerTaunt"
tt = RT("tower_engineer_2", "tower_engineer_1")
tt.info.enc_icon = 8
tt.tower.level = 2
tt.tower.price = 220
tt.attacks.list[1].bullet = "bomb_dynamite"
tt.attacks.list[1].cooldown = 3
tt.attacks.list[1].shoot_time = fts(12)
tt.attacks.list[1].bullet_start_offset = v(0, 53)

for i = 2, 8 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "towerengineerlvl2_layer" .. i - 1
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].offset = v(0, 42)
end

tt = RT("tower_engineer_3", "tower_engineer_1")
tt.info.enc_icon = 12
tt.tower.level = 3
tt.tower.price = 320
tt.attacks.range = 179.20000000000002
tt.attacks.list[1].bullet = "bomb_black"
tt.attacks.list[1].cooldown = 3
tt.attacks.list[1].shoot_time = fts(12)
tt.attacks.list[1].bullet_start_offset = v(0, 57)

for i = 2, 8 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "towerengineerlvl3_layer" .. i - 1
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].offset = v(0, 43)
end

tt = RT("tower_archer_1", "tower")

AC(tt, "attacks")

tt.tower.type = "archer"
tt.tower.level = 1
tt.tower.price = 70
tt.info.portrait = (IS_PHONE and "portraits_towers_" or "info_portraits_towers_") .. "0001"
tt.info.enc_icon = 1
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_archer_%04i"
tt.render.sprites[1].offset = v(0, 12)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "archer_tower_0001"
tt.render.sprites[2].offset = v(0, 37)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "shooterarcherlvl1"
tt.render.sprites[3].name = "idleDown"
tt.render.sprites[3].angles = {
	idle = {
		"idleUp",
		"idleDown"
	},
	shoot = {
		"shootingUp",
		"shootingDown"
	}
}
tt.render.sprites[3].offset = v(-9, 51)
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].prefix = "shooterarcherlvl1"
tt.render.sprites[4].name = "idleDown"
tt.render.sprites[4].angles = {
	idle = {
		"idleUp",
		"idleDown"
	},
	shoot = {
		"shootingUp",
		"shootingDown"
	}
}
tt.render.sprites[4].offset = v(9, 51)
tt.main_script.insert = scripts.tower_archer.insert
tt.main_script.update = scripts.tower_archer.update
tt.main_script.remove = scripts.tower_archer.remove
tt.attacks.range = 140
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].bullet = "arrow_1"
tt.attacks.list[1].cooldown = 0.8
tt.attacks.list[1].shoot_time = fts(5)
tt.attacks.list[1].bullet_start_offset = {
	v(-10, 50),
	v(10, 50)
}
tt.sound_events.insert = "ArcherTaunt"
tt = RT("tower_archer_2", "tower_archer_1")
tt.info.enc_icon = 5
tt.tower.level = 2
tt.tower.price = 110
tt.render.sprites[2].name = "archer_tower_0002"
tt.render.sprites[3].prefix = "shooterarcherlvl2"
tt.render.sprites[3].offset = v(-9, 52)
tt.render.sprites[4].prefix = "shooterarcherlvl2"
tt.render.sprites[4].offset = v(9, 52)
tt.attacks.range = 160
tt.attacks.list[1].bullet = "arrow_2"
tt.attacks.list[1].cooldown = 0.6
tt = RT("tower_archer_3", "tower_archer_1")
tt.info.enc_icon = 9
tt.tower.level = 3
tt.tower.price = 160
tt.render.sprites[2].name = "archer_tower_0003"
tt.render.sprites[3].prefix = "shooterarcherlvl3"
tt.render.sprites[3].offset = v(-9, 57)
tt.render.sprites[4].prefix = "shooterarcherlvl3"
tt.render.sprites[4].offset = v(9, 57)
tt.attacks.range = 180
tt.attacks.list[1].bullet = "arrow_3"
tt.attacks.list[1].cooldown = 0.5
tt = RT("tower_barrack_1", "tower")

AC(tt, "barrack")

tt.tower.type = "barrack"
tt.tower.level = 1
tt.tower.price = 70
tt.info.fn = scripts.tower_barrack.get_info
tt.info.portrait = IS_PHONE and "portraits_towers_0002" or "info_portraits_towers_0007"
tt.info.enc_icon = 2
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_barrack_%04i"
tt.render.sprites[1].offset = v(0, 13)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "tower_barracks_lvl1_layer1_0001"
tt.render.sprites[2].offset = v(0, 38)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "towerbarracklvl1_door"
tt.render.sprites[3].name = "close"
tt.render.sprites[3].loop = false
tt.render.sprites[3].offset = v(0, 38)
tt.barrack.soldier_type = "soldier_militia"
tt.barrack.rally_range = 145
tt.barrack.respawn_offset = v(0, 0)
tt.main_script.insert = scripts.tower_barrack.insert
tt.main_script.update = scripts.tower_barrack.update
tt.main_script.remove = scripts.tower_barrack.remove
tt.sound_events.insert = "BarrackTaunt"
tt.sound_events.change_rally_point = "BarrackTaunt"
tt = RT("tower_barrack_2", "tower_barrack_1")
tt.info.enc_icon = 6
tt.tower.level = 2
tt.tower.price = 110
tt.render.sprites[2].name = "tower_barracks_lvl2_layer1_0001"
tt.render.sprites[3].prefix = "towerbarracklvl2_door"
tt.barrack.soldier_type = "soldier_footmen"
tt = RT("tower_barrack_3", "tower_barrack_1")
tt.info.enc_icon = 10
tt.tower.level = 3
tt.tower.price = 160
tt.render.sprites[2].name = "tower_barracks_lvl3_layer1_0001"
tt.render.sprites[3].prefix = "towerbarracklvl3_door"
tt.barrack.soldier_type = "soldier_knight"

--奥数法师
tt = RT("tower_arcane_wizard", "tower_mage_1")
AC(tt, "attacks", "powers")
image_y = 90
tt.tower.type = "arcane_wizard"
tt.tower.level = 1
tt.tower.price = 300
tt.tower.size = TOWER_SIZE_LARGE
tt.tower.menu_offset = v(0, 14)
tt.info.enc_icon = 15
tt.info.i18n_key = "TOWER_ARCANE"
tt.info.fn = scripts.tower_arcane_wizard.get_info
tt.info.portrait = IS_PHONE and "portraits_towers_0005" or "info_portraits_towers_0008"
tt.powers.disintegrate = CC("power")
tt.powers.disintegrate.price_base = 350
tt.powers.disintegrate.price_inc = 400
tt.powers.disintegrate.cooldown_base = 20
tt.powers.disintegrate.cooldown_inc = -2
tt.powers.disintegrate.enc_icon = 15
tt.powers.disintegrate.name = "DESINTEGRATE"
tt.powers.teleport = CC("power")
tt.powers.teleport.price_base = 300
tt.powers.teleport.price_inc = 300
tt.powers.teleport.max_count_base = 3
tt.powers.teleport.max_count_inc = 1*2
tt.powers.teleport.enc_icon = 16
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_mage_%04i"
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "tower_arcane_wizard"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].offset = v(0, 40)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "tower_arcane_wizard_shooter"
tt.render.sprites[3].name = "idleDown"
tt.render.sprites[3].angles = {
	idle = {
		"idleUp",
		"idleDown"
	},
	shoot = {
		"shootingUp",
		"shootingDown"
	},
	teleport = {
		"teleportUp",
		"teleportDown"
	}
}
tt.render.sprites[3].offset = v(0, 58)
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].name = "fx_tower_arcane_wizard_teleport"
tt.render.sprites[4].loop = false
tt.render.sprites[4].ts = -10
tt.render.sprites[4].offset = v(-1, 90)
tt.main_script.update = scripts.tower_arcane_wizard.update
tt.sound_events.insert = "MageArcaneTaunt"
tt.attacks.range = 200*1.25
tt.attacks.min_cooldown = 1
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet = "ray_arcane"
tt.attacks.list[1].cooldown = 2
tt.attacks.list[1].node_prediction = fts(5)
tt.attacks.list[1].shoot_time = fts(20)
tt.attacks.list[1].bullet_start_offset = v(0, 76)
tt.attacks.list[2] = table.deepclone(tt.attacks.list[1])
tt.attacks.list[2].bullet = "ray_arcane_disintegrate"
tt.attacks.list[2].cooldown = 20
tt.attacks.list[2].vis_flags = bor(F_DISINTEGRATED)
tt.attacks.list[2].vis_bans = bor(F_BOSS)
tt.attacks.list[3] = CC("aura_attack")
tt.attacks.list[3].animation = "teleport"
tt.attacks.list[3].shoot_time = fts(4)
tt.attacks.list[3].cooldown = 10
tt.attacks.list[3].aura = "aura_teleport_arcane"
tt.attacks.list[3].min_nodes = 15
tt.attacks.list[3].node_prediction = fts(4)
tt.attacks.list[3].vis_flags = bor(F_RANGED, F_MOD, F_TELEPORT)
tt.attacks.list[3].vis_bans = bor(F_BOSS, F_FREEZE)

--黄法塔
tt = RT("tower_sorcerer", "tower_mage_1")
AC(tt, "attacks", "powers", "barrack")
image_y = 74
tt.tower.type = "sorcerer"
tt.tower.level = 1
tt.tower.price = 300
tt.tower.size = TOWER_SIZE_LARGE
tt.tower.menu_offset = v(0, 14)
tt.info.enc_icon = 19
tt.info.i18n_key = "TOWER_SORCERER"
tt.info.portrait = IS_PHONE and "portraits_towers_0006" or "info_portraits_towers_0011"
tt.barrack.soldier_type = "soldier_elemental"
tt.barrack.rally_range = 180*1.35
tt.powers.polymorph = CC("power")
tt.powers.polymorph.price_base = 300
tt.powers.polymorph.price_inc = 450
tt.powers.polymorph.cooldown_base = 22
tt.powers.polymorph.cooldown_inc = -2
tt.powers.polymorph.enc_icon = 1
tt.powers.polymorph.name = "POLIMORPH"
tt.powers.elemental = CC("power")
tt.powers.elemental.price_base = 350
tt.powers.elemental.price_inc = 450
tt.powers.elemental.enc_icon = 2
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_mage_%04i"
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "tower_sorcerer"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].offset = v(0, 34)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "tower_sorcerer_shooter"
tt.render.sprites[3].name = "idleDown"
tt.render.sprites[3].angles = {
	idle = {
		"idleUp",
		"idleDown"
	},
	shoot = {
		"shootingUp",
		"shootingDown"
	},
	polymorph = {
		"polymorphUp",
		"polymorphDown"
	}
}
tt.render.sprites[3].offset = v(1, 64)
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].name = "fx_tower_sorcerer_polymorph"
tt.render.sprites[4].loop = false
tt.render.sprites[4].ts = -10
tt.render.sprites[4].offset = v(0, 80)
tt.render.sprites[4].hidden = true
tt.render.sprites[4].hide_after_runs = 1
tt.main_script.insert = scripts.tower_barrack.insert
tt.main_script.update = scripts.tower_sorcerer.update
tt.main_script.remove = scripts.tower_barrack.remove
tt.sound_events.insert = "MageSorcererTaunt"
tt.sound_events.change_rally_point = "RockElementalRally"
tt.attacks.range = 200*1.75
tt.attacks.min_cooldown = 0.3
-- 新增定义一个多目标攻击逻辑  
-- 修改现有子弹攻击逻辑为多目标  
tt.attacks.list[1] = CC("bullet_attack")  
tt.attacks.list[1].animation = "shoot"  
tt.attacks.list[1].bullet = "bolt_sorcerer"  
tt.attacks.list[1].bullet_start_offset = {  
	v(8, 68),  
	v(-6, 68)  
}  
tt.attacks.list[1].cooldown = 0.3  
tt.attacks.list[1].shoot_time = fts(11)  
tt.attacks.list[1].multi_target = true -- 新属性：支持多目标  

tt.attacks.list[2] = CC("bullet_attack")  
tt.attacks.list[2].bullet_start_offset = {  
	v(0, 78),  
	v(0, 78)  
}  
tt.attacks.list[2].animation = "polymorph"  
tt.attacks.list[2].bullet = "ray_sorcerer_polymorph"  
tt.attacks.list[2].cooldown = 20  
tt.attacks.list[2].shoot_time = fts(9)  
tt.attacks.list[2].vis_bans = bor(F_BOSS)  
tt.attacks.list[2].vis_flags = bor(F_MOD, F_RANGED, F_POLYMORPH)  
tt.attacks.list[2].multi_target = true -- 新属性：支持多目标  

--大贝莎
tt = RT("tower_bfg", "tower")
AC(tt, "attacks", "powers")
image_y = 120
tt.tower.type = "bfg"
tt.tower.level = 1
tt.tower.price = 400
tt.tower.size = TOWER_SIZE_LARGE
tt.tower.menu_offset = v(0, 14)
tt.info.enc_icon = 16
tt.info.i18n_key = "TOWER_BFG"
tt.info.portrait = IS_PHONE and "portraits_towers_0012" or "info_portraits_towers_0002"
tt.powers.missile = CC("power")
tt.powers.missile.price_base = 250
tt.powers.missile.price_inc = 100
tt.powers.missile.range_inc_factor = 0.2
tt.powers.missile.damage_inc = 90
tt.powers.missile.enc_icon = 17
tt.powers.cluster = CC("power")
tt.powers.cluster.price_base = 250
tt.powers.cluster.price_inc = 250
tt.powers.cluster.fragment_count_base = 3
tt.powers.cluster.fragment_count_inc = 3
tt.powers.cluster.enc_icon = 18
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_artillery_bfg_%04i"
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "tower_bfg"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].offset = v(0, 51)
tt.main_script.update = scripts.tower_bfg.update
tt.sound_events.insert = "EngineerBfgTaunt"
tt.attacks.min_cooldown = 1.75
tt.attacks.range = 180*1.15
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet = "bomb_bfg"
tt.attacks.list[1].bullet_start_offset = v(0, 64)
tt.attacks.list[1].cooldown = 1.25
tt.attacks.list[1].node_prediction = fts(25)
tt.attacks.list[1].range = 180*1.15
tt.attacks.list[1].shoot_time = fts(23)
tt.attacks.list[1].vis_bans = bor(F_FLYING)
tt.attacks.list[2] = CC("bullet_attack")
tt.attacks.list[2].animation = "missile"
tt.attacks.list[2].bullet = "missile_bfg"
tt.attacks.list[2].bullet_start_offset = v(-24, 64)
tt.attacks.list[2].cooldown = 5.1
tt.attacks.list[2].cooldown_mixed = 5.1
tt.attacks.list[2].cooldown_flying = 6.5
tt.attacks.list[2].launch_vector = v(12, 110)
tt.attacks.list[2].range_base = 180*1.15
tt.attacks.list[2].range = nil
tt.attacks.list[2].shoot_time = fts(14)
tt.attacks.list[2].vis_flags = bor(F_MOD, F_RANGED)
tt.attacks.list[3] = table.deepclone(tt.attacks.list[1])
tt.attacks.list[3].bullet = "bomb_bfg_cluster"
tt.attacks.list[3].cooldown = 7
tt.attacks.list[3].node_prediction = fts(44)

--特斯拉
tt = RT("tower_tesla", "tower")
AC(tt, "attacks", "powers")
image_y = 96
tt.tower.type = "tesla"
tt.tower.level = 1
tt.tower.price = 375
tt.tower.size = TOWER_SIZE_LARGE
tt.tower.menu_offset = v(0, 14)
tt.info.enc_icon = 20
tt.info.fn = scripts.tower_tesla.get_info
tt.info.i18n_key = "TOWER_TESLA"
tt.info.portrait = IS_PHONE and "portraits_towers_0011" or "info_portraits_towers_0009"
tt.powers.bolt = CC("power")
tt.powers.bolt.price_base = 250
tt.powers.bolt.price_inc = 250
tt.powers.bolt.max_level = 2
tt.powers.bolt.jumps_base = 3
tt.powers.bolt.jumps_inc = 1
tt.powers.bolt.enc_icon = 11
tt.powers.bolt.name = "CHARGED_BOLT"
tt.powers.overcharge = CC("power")
tt.powers.overcharge.price_base = 250
tt.powers.overcharge.price_inc = 205
tt.powers.overcharge.enc_icon = 10
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_artillery_tesla_%04i"
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "tower_tesla"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].offset = v(0, 40)
tt.main_script.update = scripts.tower_tesla.update
tt.sound_events.insert = "EngineerTeslaTaunt"
tt.attacks.min_cooldown = 1.2
tt.attacks.range = 165*1.25
tt.attacks.range_check_factor = 1.2
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet = "ray_tesla"
tt.attacks.list[1].bullet_start_offset = v(7, 79)
tt.attacks.list[1].cooldown = 1.2
tt.attacks.list[1].node_prediction = fts(18)
tt.attacks.list[1].range = 165*1.25
tt.attacks.list[1].shoot_time = fts(48)
tt.attacks.list[1].sound_shoot = "TeslaAttack"
tt.attacks.list[2] = CC("aura_attack")
tt.attacks.list[2].aura = "aura_tesla_overcharge"
tt.attacks.list[2].bullet_start_offset = v(0, 15)

-- 游侠塔
tt = RT("tower_ranger", "tower_archer_1")
AC(tt, "attacks", "powers")
image_y = 90
tt.tower.type = "ranger"
tt.tower.level = 1
tt.tower.price = 230
tt.tower.size = TOWER_SIZE_LARGE
tt.info.enc_icon = 13
tt.info.i18n_key = "TOWER_RANGERS"
tt.info.portrait = IS_PHONE and "portraits_towers_0010" or "info_portraits_towers_0006"
tt.powers.poison = CC("power")
tt.powers.poison.price_base = 250
tt.powers.poison.price_inc = 250
tt.powers.poison.mod = "mod_ranger_poison"
tt.powers.poison.enc_icon = 8
tt.powers.thorn = CC("power")
tt.powers.thorn.price_base = 300
tt.powers.thorn.price_inc = 250
tt.powers.thorn.aura = "aura_ranger_thorn"
tt.powers.thorn.enc_icon = 9
tt.powers.thorn.name = "thorns"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_archer_ranger_%04i"
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "archer_tower_0005"
tt.render.sprites[2].offset = v(0, 40)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "tower_ranger_shooter"
tt.render.sprites[3].name = "idleDown"
tt.render.sprites[3].angles = {
	idle = {
		"idleUp",
		"idleDown"
	},
	shoot = {
		"shootingUp",
		"shootingDown"
	}
}
tt.render.sprites[3].offset = v(-8, 65)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[4].offset.x = 8
tt.render.sprites[5] = CC("sprite")
tt.render.sprites[5].prefix = "tower_ranger_druid"
tt.render.sprites[5].name = "idle"
tt.render.sprites[5].hidden = true
tt.render.sprites[5].offset = v(31, 15)
tt.main_script.update = scripts.tower_ranger.update
tt.attacks.range = 200*1.45
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet = "arrow_ranger"
tt.attacks.list[1].cooldown = 0.22
tt.attacks.list[1].shoot_time = fts(4)
tt.attacks.list[1].shooters_delay = 0.1
tt.attacks.list[1].bullet_start_offset = {
	v(8, 4),
	v(4, -5)
}
tt.sound_events.insert = "ArcherRangerTaunt"

-- 火枪要塞
tt = RT("tower_musketeer", "tower_archer_1")
AC(tt, "attacks", "powers")
image_y = 90
tt.tower.type = "musketeer"
tt.tower.level = 1
tt.tower.price = 230
tt.tower.size = TOWER_SIZE_LARGE
tt.info.enc_icon = 17
tt.info.i18n_key = "TOWER_MUSKETEERS"
tt.info.portrait = IS_PHONE and "portraits_towers_0009" or "info_portraits_towers_0004"
tt.powers.sniper = CC("power")
tt.powers.sniper.attack_idx = 2
tt.powers.sniper.price_base = 250
tt.powers.sniper.price_inc = 250
tt.powers.sniper.damage_factor_inc = 0.2
tt.powers.sniper.instakill_chance_inc = 0.2
tt.powers.sniper.enc_icon = 3
tt.powers.shrapnel = CC("power")
tt.powers.shrapnel.attack_idx = 3
tt.powers.shrapnel.price_base = 300
tt.powers.shrapnel.price_inc = 300
tt.powers.shrapnel.enc_icon = 4
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_archer_musketeer_%04i"
tt.render.sprites[1].offset = v(0, 14)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "archer_tower_0004"
tt.render.sprites[2].offset = v(0, 37)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "tower_musketeer_shooter"
tt.render.sprites[3].name = "idleDown"
tt.render.sprites[3].angles = {
	idle = {
		"idleUp",
		"idleDown"
	},
	shoot = {
		"shootingUp",
		"shootingDown"
	},
	sniper_shoot = {
		"sniperShootUp",
		"sniperShootDown"
	},
	sniper_seek = {
		"sniperSeekUp",
		"sniperSeekDown"
	},
	cannon_shoot = {
		"cannonShootUp",
		"cannonShootDown"
	},
	cannon_fuse = {
		"cannonFuseUp",
		"cannonFuseDown"
	}
}
tt.render.sprites[3].offset = v(-8, 56)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[4].offset.x = 8
tt.main_script.update = scripts.tower_musketeer.update
tt.sound_events.insert = "ArcherMusketeerTaunt"
tt.attacks.range = 235*1.45
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet = "shotgun_musketeer"
tt.attacks.list[1].cooldown = 1
tt.attacks.list[1].shoot_time = fts(6)
tt.attacks.list[1].shooters_delay = 0.1
tt.attacks.list[1].bullet_start_offset = {
	v(6, 8),
	v(4, -5)
}
tt.attacks.list[2] = CC("bullet_attack")
tt.attacks.list[2].animation = "sniper_shoot"
tt.attacks.list[2].animation_seeker = "sniper_seek"
tt.attacks.list[2].bullet = "shotgun_musketeer_sniper"
tt.attacks.list[2].bullet_start_offset = tt.attacks.list[1].bullet_start_offset
tt.attacks.list[2].cooldown = 14*0.5
tt.attacks.list[2].power_name = "sniper"
tt.attacks.list[2].shoot_time = fts(22)
tt.attacks.list[2].vis_flags = bor(F_INSTAKILL)
tt.attacks.list[2].vis_bans = bor(F_BOSS)
tt.attacks.list[2].range = tt.attacks.range * 1.5
tt.attacks.list[3] = table.deepclone(tt.attacks.list[2])
tt.attacks.list[3].chance = 0
tt.attacks.list[3].bullet = "shotgun_musketeer_sniper_instakill"
tt.attacks.list[4] = CC("bullet_attack")
tt.attacks.list[4].animation = "cannon_shoot"
tt.attacks.list[4].animation_seeker = "cannon_fuse"
tt.attacks.list[4].bullet = "bomb_musketeer"
tt.attacks.list[4].loops = 9
tt.attacks.list[4].bullet_start_offset = tt.attacks.list[1].bullet_start_offset
tt.attacks.list[4].cooldown = 9*0.5
tt.attacks.list[4].power_name = "shrapnel"
tt.attacks.list[4].range = tt.attacks.range 
tt.attacks.list[4].shoot_time = fts(16)
tt.attacks.list[4].node_prediction = fts(6)
tt.attacks.list[4].min_spread = 12.5*1.25
tt.attacks.list[4].max_spread = 32.5*1.25
tt.attacks.list[4].vis_bans = bor(F_FLYING)
tt.attacks.list[4].shoot_fx = "fx_rifle_smoke"

--骑士兵营
tt = RT("tower_paladin", "tower_barrack_1")

AC(tt, "powers")

tt.info.portrait = IS_PHONE and "portraits_towers_0007" or "info_portraits_towers_0005"
tt.info.enc_icon = 14
tt.info.i18n_key = "TOWER_PALADINS"
tt.tower.type = "paladin"
tt.tower.price = 230
tt.powers.healing = E:clone_c("power")
tt.powers.healing.price_base = 250
tt.powers.healing.price_inc = 450
tt.powers.healing.enc_icon = 6
tt.powers.shield = E:clone_c("power")
tt.powers.shield.price_base = 250
tt.powers.shield.price_inc = 100
tt.powers.shield.max_level = 1
tt.powers.shield.enc_icon = 7
tt.powers.holystrike = E:clone_c("power")
tt.powers.holystrike.price_base = 120
tt.powers.holystrike.price_inc = 350
tt.powers.holystrike.enc_icon = 5
tt.powers.holystrike.name = "HOLY_STRIKE"
tt.barrack.soldier_type = "soldier_paladin"
tt.barrack.rally_range = 285
tt.barrack.max_soldiers = 9
tt.render.sprites[1].name = "terrain_barrack_%04i"
tt.render.sprites[1].offset = v(0, 13)
tt.render.sprites[2].name = "tower_barracks_lvl4_Paladins_layer1_0001"
tt.render.sprites[2].offset = v(0, 39)
tt.render.sprites[3].prefix = "towerbarracklvl4_paladin_door"
tt.render.sprites[3].offset = v(0, 39)
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].name = "tower_paladin_flag"
tt.render.sprites[4].offset = v(7, 72)
tt.sound_events.insert = "BarrackPaladinTaunt"
tt.sound_events.change_rally_point = "BarrackPaladinTaunt"

--野蛮人
tt = RT("tower_barbarian", "tower_barrack_1")
AC(tt, "powers")
tt.info.portrait = IS_PHONE and "portraits_towers_0008" or "info_portraits_towers_0012"
tt.info.enc_icon = 18
tt.info.i18n_key = "TOWER_BARBARIANS"
tt.tower.type = "barbarian"
tt.tower.price = 230
tt.powers.dual = E:clone_c("power")
tt.powers.dual.price_base = 100
tt.powers.dual.price_inc = 100
tt.powers.dual.enc_icon = 12
tt.powers.dual.name = "DOUBLE_AXE"
tt.powers.twister = E:clone_c("power")
tt.powers.twister.price_base = 150
tt.powers.twister.price_inc = 100
tt.powers.twister.enc_icon = 13
tt.powers.throwing = E:clone_c("power")
tt.powers.throwing.price_base = 200
tt.powers.throwing.price_inc = 100
tt.powers.throwing.enc_icon = 14
tt.powers.throwing.name = "THROWING_AXES"
tt.barrack.soldier_type = "soldier_barbarian"
tt.barrack.rally_range = 245
tt.render.sprites[1].name = "terrain_barrack_%04i"
tt.render.sprites[1].offset = v(0, 13)
tt.render.sprites[2].name = "tower_barrack_lvl4_Barbarians_layer1_0001"
tt.render.sprites[2].offset = v(0, 39)
tt.render.sprites[3].prefix = "towerbarracklvl4_barbarian_door"
tt.render.sprites[3].offset = v(0, 39)
tt.sound_events.insert = "BarrackBarbarianTaunt"
tt.sound_events.change_rally_point = "BarrackBarbarianTaunt"
tt = RT("tower_elf_holder")

AC(tt, "tower", "tower_holder", "pos", "render", "ui", "info", "editor", "editor_script")

tt.tower.type = "holder_elf"
tt.tower.level = 1
tt.tower.can_be_mod = false
tt.info.i18n_key = "SPECIAL_ELF"
tt.info.fn = scripts.tower_elf_holder.get_info
tt.info.portrait = (IS_PHONE and "portraits_towers" or "info_portraits_towers") .. "_0013"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_barrack_%04i"
tt.render.sprites[1].offset = v(0, 2)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "elfTower_layer1_0026"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(0, 20)
tt.ui.click_rect = r(-40, -10, 80, 90)
tt.ui.has_nav_mesh = true
tt.editor.props = {
	{
		"tower.terrain_style",
		PT_NUMBER
	},
	{
		"tower.default_rally_pos",
		PT_COORDS
	},
	{
		"tower.holder_id",
		PT_STRING
	},
	{
		"ui.nav_mesh_id",
		PT_STRING
	},
	{
		"editor.game_mode",
		PT_NUMBER
	}
}
tt.editor_script.insert = scripts.editor_tower.insert
tt.editor_script.remove = scripts.editor_tower.remove
tt = RT("tower_elf", "tower")

AC(tt, "barrack")

tt.info.portrait = (IS_PHONE and "portraits_towers" or "info_portraits_towers") .. "_0013"
tt.barrack.max_soldiers = 4
tt.barrack.rally_range = 145
tt.barrack.respawn_offset = v(0, 0)
tt.barrack.soldier_type = "soldier_elf"
tt.editor.props = table.append(tt.editor.props, {
	{
		"barrack.rally_pos",
		PT_COORDS
	}
}, true)
tt.info.i18n_key = "SPECIAL_ELF"
tt.info.fn = scripts.tower_elf_holder.get_info
tt.main_script.insert = scripts.tower_barrack.insert
tt.main_script.remove = scripts.tower_barrack.remove
tt.main_script.update = scripts.tower_barrack_mercenaries.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_barrack_%04i"
tt.render.sprites[1].offset = v(0, 2)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "elfTower_layer1_0001"
tt.render.sprites[2].offset = v(0, 20)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].loop = false
tt.render.sprites[3].name = "close"
tt.render.sprites[3].offset = v(0, 20)
tt.render.sprites[3].prefix = "tower_elf_door"
tt.render.door_sid = 3
tt.sound_events.change_rally_point = "ElfTaunt"
tt.sound_events.insert = "GUITowerBuilding"
tt.sound_events.mute_on_level_insert = true
tt.tower.can_be_mod = false
tt.tower.level = 1
tt.tower.price = 100
tt.tower.terrain_style = nil
tt.tower.type = "elf"
tt.ui.click_rect = r(-40, -10, 80, 90)
tt = RT("tower_sasquash_holder")

AC(tt, "tower", "tower_holder", "pos", "render", "ui", "info", "editor", "main_script")

tt.tower.type = "holder_sasquash"
tt.tower.level = 1
tt.tower.can_be_mod = false
tt.main_script.update = scripts.tower_sasquash_holder.update
tt.info.i18n_key = "SPECIAL_SASQUASH_REPAIR"
tt.info.fn = scripts.tower_barrack_mercenaries.get_info
tt.info.portrait = (IS_PHONE and "portraits_towers" or "info_portraits_towers") .. "_0014"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "sasquash_frozen_0001"
tt.render.sprites[1].offset = v(-9, 13)
tt.render.sprites[1].z = Z_TOWER_BASES - 2
tt.ui.click_rect = r(-40, -30, 80, 90)
tt.unfreeze_radius = 60
tt.unfreeze_fx = "fx_tower_sasquash_unfreeze"
tt.unfreeze_upgrade_to = "tower_sasquash"
tt.unfreeze_rect = r(290, 480, 120, 90)
tt = RT("fx_tower_sasquash_unfreeze", "fx")
tt.render.sprites[1].name = "tower_sasquash_unfreeze"
tt.render.sprites[1].offset = v(-9, 13)
tt.render.sprites[1].z = Z_EFFECTS
tt = RT("tower_sasquash", "tower")

AC(tt, "barrack")

tt.info.portrait = (IS_PHONE and "portraits_towers" or "info_portraits_towers") .. "_0014"
tt.barrack.max_soldiers = 1
tt.barrack.rally_range = 288
tt.barrack.respawn_offset = v(-60, 0)
tt.barrack.soldier_type = "soldier_sasquash"
tt.barrack.has_door = nil
tt.editor.props = table.append(tt.editor.props, {
	{
		"barrack.rally_pos",
		PT_COORDS
	}
}, true)
tt.info.i18n_key = "SPECIAL_SASQUASH"
tt.info.fn = scripts.tower_sasquash_holder.get_info
tt.main_script.insert = scripts.tower_barrack.insert
tt.main_script.remove = scripts.tower_barrack.remove
tt.main_script.update = scripts.tower_barrack_mercenaries.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "sasquash_cave_inside"
tt.render.sprites[1].offset = v(-9, 13)
tt.render.sprites[1].z = Z_TOWER_BASES - 2
tt.sound_events.change_rally_point = "SasquashRally"
tt.sound_events.insert = nil
tt.sound_events.mute_on_level_insert = true
tt.tower.can_be_mod = false
tt.tower.can_be_sold = false
tt.tower.level = 1
tt.tower.price = 0
tt.tower.terrain_style = nil
tt.tower.type = "sasquash"
tt.ui.click_rect = r(-40, -30, 80, 90)
tt.ui.has_nav_mesh = true
tt = RT("tower_sunray", "tower")

AC(tt, "powers", "user_selection", "attacks")

tt.tower.level = 1
tt.tower.type = "sunray"
tt.tower.price = 500
tt.tower.can_be_mod = false
tt.tower.terrain_style = nil
tt.info.portrait = IS_PHONE and "portraits_towers_0015" or "info_portraits_towers_0015"
tt.info.fn = scripts.tower_sunray.get_info
tt.info.i18n_key = "SPECIAL_SUNRAY"
tt.ui.click_rect = r(-55, -40, 110, 130)
tt.powers.ray = E:clone_c("power")
tt.powers.ray.level = 0
tt.powers.ray.max_level = 4
tt.powers.ray.price_base = 100
tt.powers.ray.price_inc = 100
tt.main_script.insert = scripts.tower_sunray.insert
tt.main_script.update = scripts.tower_sunray.update
tt.render.sprites[1].name = "sunrayTower_layer1_0068"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset = IS_CONSOLE and v(-6.5, 25) or v(-6, 51)
tt.render.sprites[1].hidden = true
tt.render.sprites[1].hover_off_hidden = true
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "sunrayTower_layer1_0001"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(-6, 25)

for i = 3, 6 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].name = "disabled"
	tt.render.sprites[i].offset = v(-6, 25)
	tt.render.sprites[i].prefix = "tower_sunray_layer" .. i - 1
	tt.render.sprites[i].group = "tower"
end

for i = 7, 10 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].animated = true
	tt.render.sprites[i].hidden = true
	tt.render.sprites[i].anchor.y = 0.11764705882352941
	tt.render.sprites[i].prefix = "tower_sunray_shooter_" .. (i % 2 == 0 and "down" or "up")
end

tt.render.sprites[7].offset = v(33, -10)
tt.render.sprites[8].offset = v(-25, 22)
tt.render.sprites[9].offset = v(-29, -11)
tt.render.sprites[10].offset = v(30, 22)
tt.sound_events.mute_on_level_insert = true
tt.user_selection.can_select_point_fn = scripts.tower_sunray.can_select_point
tt.user_selection.custom_pointer_name = "sunray_tower"
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].bullet = "ray_sunray"
tt.attacks.list[1].cooldown = 19
tt.attacks.list[1].cooldown_base = 22
tt.attacks.list[1].cooldown_inc = -3
tt.attacks.list[1].bullet_start_offset = v(0, 80)
tt.attacks.list[1].range = 2000
tt.attacks.list[1].shoot_time = fts(3)
tt = RT("soldier_elemental", "soldier_militia")

AC(tt, "melee")

image_y = 64
anchor_y = 0.15384615384615385
tt.health.armor = 0.3
tt.health.armor_inc = 0.1
tt.health.dead_lifetime = 8
tt.health.hp_max = 500
tt.health.hp_inc = 100
tt.health_bar.offset = v(0, 55)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "SOLDIER_ELEMENTAL"
tt.info.portrait = IS_PHONE and "portraits_sc_0017" or "info_portraits_sc_0017"
tt.info.random_name_count = nil
tt.info.random_name_format = nil
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].count = 4
tt.melee.attacks[1].damage_inc = 10
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].damage_radius = 37.5
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = v(35, 0)
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].pop = {
	"pop_whaam",
	"pop_kapow"
}
tt.melee.attacks[1].pop_chance = 0.3
tt.melee.attacks[1].sound_hit = "AreaAttack"
tt.melee.range = 75
tt.motion.max_speed = 39
tt.regen.health = 20
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles = {
	walk = {
		"running"
	}
}
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].prefix = "soldier_elemental"
tt.soldier.melee_slot_offset = v(15, 0)
tt.sound_events.insert = "RockElementalDeath"
tt.sound_events.death = "RockElementalDeath"
tt.ui.click_rect = r(-25, -2, 50, 52)
tt.unit.blood_color = BLOOD_GRAY
tt.unit.hit_offset = v(0, 15)
tt.unit.marker_offset = v(0, -2)
tt.unit.mod_offset = v(0, 16)
tt.vis.bans = bor(F_LYCAN)
tt = RT("soldier_paladin", "soldier_militia")

E:add_comps(tt, "powers", "timed_actions")

anchor_y = 0.17
image_y = 42
tt.health.armor = 0.5
tt.health.dead_lifetime = 12
tt.health.hp_max = 440
tt.health.armor_power_name = "shield"
tt.health.armor_inc = 0.2
tt.health_bar.offset = v(0, ady(40))
tt.info.portrait = IS_PHONE and "portraits_sc_0004" or "info_portraits_sc_0004"
tt.info.random_name_count = 20
tt.info.random_name_format = "SOLDIER_PALADIN_RANDOM_%i_NAME"
tt.melee.attacks[1].damage_max = 18
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[3] = E:clone_c("area_attack")
tt.melee.attacks[3].animation = "holystrike"
tt.melee.attacks[3].chance = 0.2
tt.melee.attacks[3].damage_max = 0
tt.melee.attacks[3].damage_min = 0
tt.melee.attacks[3].damage_max_inc = 95
tt.melee.attacks[3].damage_min_inc = 65
tt.melee.attacks[3].damage_radius = 50
tt.melee.attacks[3].damage_type = DAMAGE_TRUE	
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].hit_decal = "decal_paladin_holystrike"
tt.melee.attacks[3].hit_offset = v(22, 0)
tt.melee.attacks[3].hit_time = fts(15)
tt.melee.attacks[3].level = 0
tt.melee.attacks[3].pop = nil
tt.melee.attacks[3].power_name = "holystrike"
tt.melee.attacks[3].shared_cooldown = true
tt.melee.attacks[3].signal = "holystrike"
tt.melee.attacks[3].vis_bans = bor(F_FLYING)
tt.melee.attacks[3].vis_flags = bor(F_BLOCK)
tt.melee.cooldown = 1 + fts(13)
tt.melee.range = 60
tt.motion.max_speed = 75*1.5
tt.powers.healing = E:clone_c("power")
tt.powers.shield = E:clone_c("power")
tt.powers.holystrike = E:clone_c("power")
tt.regen.health = 25
tt.render.sprites[1].prefix = "soldier_paladin"
tt.render.sprites[1].anchor.y = anchor_y
tt.soldier.melee_slot_offset = v(5, 0)
tt.timed_actions.list[1] = CC("mod_attack")
tt.timed_actions.list[1].animation = "healing"
tt.timed_actions.list[1].cast_time = fts(17)
tt.timed_actions.list[1].cooldown = 10
tt.timed_actions.list[1].disabled = true

tt.timed_actions.list[1].fn_can = function (t, s, a)
	return t.health.hp < a.min_health_factor * t.health.hp_max
end

tt.timed_actions.list[1].level = 0
tt.timed_actions.list[1].min_health_factor = 0.7
tt.timed_actions.list[1].mod = "mod_healing_paladin"
tt.timed_actions.list[1].power_name = "healing"
tt.timed_actions.list[1].sound = "HealingSound"
tt = RT("soldier_barbarian", "soldier_militia")

E:add_comps(tt, "powers", "ranged")

anchor_y = 0.3
image_y = 62
tt.health.armor = 0
tt.health.dead_lifetime = 10
tt.health.hp_max = 250
tt.health_bar.offset = v(0, ady(48))
tt.info.portrait = IS_PHONE and "portraits_sc_0005" or "info_portraits_sc_0005"
tt.info.random_name_count = 20
tt.info.random_name_format = "SOLDIER_BARBARIAN_RANDOM_%i_NAME"
tt.motion.max_speed = 75
tt.powers.dual = E:clone_c("power")
tt.powers.dual.on_power_upgrade = scripts.soldier_barbarian.on_power_upgrade
tt.powers.twister = E:clone_c("power")
tt.powers.throwing = E:clone_c("power")
tt.regen.health = 20
tt.render.sprites[1].prefix = "soldier_barbarian"
tt.render.sprites[1].anchor.y = anchor_y
tt.soldier.melee_slot_offset = v(5, 0)
tt.melee.cooldown = 1 + fts(11)
tt.melee.range = 60
tt.melee.attacks[1].damage_inc = 10
tt.melee.attacks[1].damage_max = 24
tt.melee.attacks[1].damage_min = 16
tt.melee.attacks[1].power_name = "dual"
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[2] = E:clone_c("area_attack")
tt.melee.attacks[2].animation = "twister"
tt.melee.attacks[2].chance = 0.1
tt.melee.attacks[2].chance_inc = 0.05
tt.melee.attacks[2].damage_inc = 15
tt.melee.attacks[2].damage_max = 30
tt.melee.attacks[2].damage_min = 10
tt.melee.attacks[2].damage_radius = 40
tt.melee.attacks[2].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].hit_time = fts(7)
tt.melee.attacks[2].level = 0
tt.melee.attacks[2].pop = nil
tt.melee.attacks[2].power_name = "twister"
tt.melee.attacks[2].shared_cooldown = true
tt.melee.attacks[2].vis_bans = bor(F_FLYING)
tt.melee.attacks[2].vis_flags = bor(F_BLOCK)
tt.ranged.go_back_during_cooldown = true
tt.ranged.range_while_blocking = true
tt.ranged.attacks[1].bullet = "axe_barbarian"
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 12)
}
tt.ranged.attacks[1].cooldown = 3 + fts(14)
tt.ranged.attacks[1].disabled = true
tt.ranged.attacks[1].level = 0
tt.ranged.attacks[1].max_range = 155
tt.ranged.attacks[1].min_range = 55
tt.ranged.attacks[1].power_name = "throwing"
tt.ranged.attacks[1].range_inc = 13
tt.ranged.attacks[1].shoot_time = fts(7)
tt = RT("soldier_elf", "soldier_militia")

AC(tt, "ranged")

image_y = 32
anchor_y = 0.19
tt.health.hp_max = 100
tt.health_bar.offset = v(0, ady(31))
tt.health.dead_lifetime = 3
tt.info.fn = scripts.soldier_mercenary.get_info
tt.info.portrait = IS_PHONE and "portraits_sc_0044" or "info_portraits_sc_0044"
tt.info.random_name_count = 10
tt.info.random_name_format = "SOLDIER_ELVES_RANDOM_%i_NAME"
tt.melee.attacks[1].damage_max = 50
tt.melee.attacks[1].damage_min = 25
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.attacks[1].track_damage = true
tt.melee.range = 75
tt.ranged.go_back_during_cooldown = true
tt.ranged.attacks[1].bullet = "arrow_elf"
tt.ranged.attacks[1].bullet_start_offset = {
	v(4, 16)
}
tt.ranged.attacks[1].cooldown = 1 + fts(15)
tt.ranged.attacks[1].max_range = 205
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].shoot_time = fts(7)
tt.regen.cooldown = 1
tt.regen.health = 20
tt.render.sprites[1].prefix = "soldier_elf"
tt.sound_events.insert = "ElfTaunt"
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, ady(22))
tt.unit.price = 100
tt = RT("soldier_sasquash", "soldier_militia")
image_y = 80
anchor_y = 0.17
tt.health.hp_max = 2500
tt.health_bar.offset = v(0, ady(73))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.dead_lifetime = 3
tt.info.fn = scripts.soldier_mercenary.get_info
tt.info.portrait = IS_PHONE and "portraits_sc_0034" or "info_portraits_sc_0034"
tt.info.i18n_key = "SOLDIER_SASQUASH"
tt.info.random_name_format = nil
tt.main_script.insert = scripts.soldier_sasquash.insert
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2.5
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 110
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].damage_radius = 35
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = v(35, 0)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].pop = {
	"pop_kapow",
	"pop_whaam"
}
tt.melee.attacks[1].pop_chance = 0.3
tt.melee.attacks[1].pop_conds = DR_KILL
tt.melee.attacks[1].sound_hit = "AreaAttack"
tt.melee.range = 83
tt.motion.max_speed = 49.5
tt.regen.cooldown = 1
tt.regen.health = 250
tt.render.sprites[1].prefix = "soldier_sasquash"
tt.soldier.melee_slot_offset = v(25, 0)
tt.sound_events.insert = "SasquashReady"
tt.ui.click_rect = r(-20, 0, 40, 40)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, ady(30))
tt.unit.price = 400
tt = RT("soldier_s6_imperial_guard", "soldier_militia")

AC(tt, "editor")

anchor_y = 0.15
anchor_x = 0.5
image_y = 41
image_x = 58
tt.health.armor = 0.4
tt.health.dead_lifetime = 3
tt.health.hp_max = 250
tt.health_bar.offset = v(adx(28), ady(40))
tt.info.fn = scripts.soldier_mercenary.get_info
tt.info.portrait = IS_PHONE and "portraits_sc_0026" or "info_portraits_sc_0026"
tt.info.random_name_count = 20
tt.info.random_name_format = "SOLDIER_PALADIN_RANDOM_%i_NAME"
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[2].hit_time = fts(6)
tt.melee.cooldown = 1
tt.melee.range = 72.5
tt.motion.max_speed = 60
tt.regen.health = 25
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "soldier_s6_imperial_guard"
tt.soldier.melee_slot_offset = v(8, 0)
tt.unit.mod_offset = v(adx(27), ady(22))
tt.editor.props = {
	{
		"editor.game_mode",
		PT_NUMBER
	}
}
tt.editor.overrides = {
	["health.hp"] = 250
}
tt = RT("re_farmer", "soldier_militia")

AC(tt, "reinforcement", "tween")

image_y = 44
anchor_y = 0.1590909090909091
tt.cooldown = 10
tt.health.armor = 0
tt.health.hp_max = 30
tt.health_bar.offset = v(0, ady(32))
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.info.portrait_idxs = {
	15,
	16,
	14
}
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 2
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.range = 60
tt.motion.max_speed = 60
tt.regen.cooldown = 1
tt.regen.health = 3
tt.reinforcement.duration = 20
tt.render.sprites[1].anchor.y = anchor_y
tt.sound_events.insert = "ReinforcementTaunt"
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(10),
		255
	}
}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.tween.reverse = false
tt.unit.level = 0
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
tt = RT("re_farmer_well_fed", "re_farmer")
tt.unit.level = 1
tt.health.hp_max = 50
tt.health.armor = 0
tt.regen.health = 6
tt.melee.attacks[1].damage_max = 3
tt = RT("re_conscript", "re_farmer")
tt.info.portrait_idxs = {
	41,
	38,
	35
}
tt.unit.level = 2
tt.health.hp_max = 70
tt.health.armor = 0.1
tt.regen.health = 9
tt.melee.attacks[1].damage_min = 2
tt.melee.attacks[1].damage_max = 4
tt = RT("re_warrior", "re_farmer")
tt.info.portrait_idxs = {
	42,
	39,
	36
}
tt.unit.level = 3
tt.health.hp_max = 90
tt.health.armor = 0.2
tt.regen.health = 12
tt.melee.attacks[1].damage_min = 3
tt.melee.attacks[1].damage_max = 6
tt = RT("re_legionnaire", "re_farmer")
tt.info.portrait_idxs = {
	43,
	40,
	37
}
tt.unit.level = 4
tt.health.hp_max = 110
tt.health.armor = 0.3
tt.health_bar.offset = v(0, ady(34))
tt.regen.health = 15
tt.melee.attacks[1].damage_min = 6
tt.melee.attacks[1].damage_max = 10
tt = RT("re_legionnaire_ranged", "re_legionnaire")

AC(tt, "ranged")

tt.unit.level = 5
tt.ranged.attacks[1].bullet = "spear_legionnaire"
tt.ranged.attacks[1].shoot_time = fts(3)
tt.ranged.attacks[1].cooldown = 1 + fts(12)
tt.ranged.attacks[1].max_range = 165
tt.ranged.attacks[1].min_range = 27
tt.ranged.attacks[1].animation = IS_PHONE and "ranged_attack_p" or "ranged_attack"
tt.ranged.attacks[1].bullet_start_offset = {
	v(6, 13)
}

for i = 1, 3 do
	for j, name in ipairs({
		"re_farmer",
		"re_farmer_well_fed",
		"re_conscript",
		"re_warrior",
		"re_legionnaire",
		"re_legionnaire_ranged"
	}) do
		local fn = name .. "_" .. i
		local base_t = E:get_template(name)
		local t = RT(fn, base_t)
		t.render.sprites[1].prefix = fn

		if IS_PHONE then
			t.info.portrait = string.format("portraits_sc_00%02d", t.info.portrait_idxs[i])
		else
			t.info.portrait = string.format("info_portraits_sc_00%02d", t.info.portrait_idxs[i])
		end
	end
end

for i = 1, 3 do
	E:set_template("re_current_" .. i, E:get_template("re_farmer_" .. i))
end

tt = RT("soldier_alleria_wildcat", "soldier")

E:add_comps(tt, "melee", "nav_grid")

anchor_y = 0.28
image_y = 42
tt.fn_level_up = scripts.soldier_alleria_wildcat.level_up
tt.info.portrait = IS_PHONE and "portraits_hero_0007" or "info_portraits_hero_0007"
tt.health.armor = 0
tt.health.hp_max = nil
tt.health_bar.offset = v(0, 35)
tt.info.fn = scripts.soldier_alleria_wildcat.get_info
tt.info.i18n_key = "HERO_ARCHER_WILDCAT"
tt.main_script.insert = scripts.soldier_alleria_wildcat.insert
tt.main_script.update = scripts.soldier_alleria_wildcat.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].vis_bans = bor(F_FLYING)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].sound = "HeroArcherWildCatHit"
tt.melee.range = 80
tt.motion.max_speed = 90
tt.regen.health = 75
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].prefix = "soldier_alleria"
tt.render.sprites[1].angles = {
	walk = {
		"running"
	}
}
tt.soldier.melee_slot_offset.x = 5
tt.ui.click_rect = IS_PHONE and r(-20, -10, 40, 40) or r(-15, -5, 30, 30)
tt.unit.hit_offset = v(0, 12)
tt.unit.mod_offset = v(0, 14)
tt.unit.hide_after_death = true
tt.unit.explode_fx = nil
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE)
tt = RT("soldier_magnus_illusion", "soldier_militia")

AC(tt, "reinforcement", "ranged", "tween")

image_y = 76
image_x = 60
anchor_y = 0.14
tt.health.hp_max = nil
tt.health_bar.offset = v(0, 33)
tt.health.dead_lifetime = fts(14)
tt.info.portrait = IS_PHONE and "portraits_hero_0005" or "info_portraits_hero_0004"
tt.info.i18n_key = "HERO_MAGE_SHADOW"
tt.info.random_name_format = nil
tt.info.fn = scripts.soldier_magnus_illusion.get_info
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.range = 45
tt.reinforcement.duration = 10
tt.reinforcement.fade = nil
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "bolt_magnus_illusion"
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 23)
}
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].damage_max = nil
tt.ranged.attacks[1].damage_min = nil
tt.ranged.attacks[1].shoot_time = fts(18)
tt.ranged.attacks[1].cooldown = fts(33)
tt.regen.cooldown = 1
tt.render.sprites[1].prefix = "soldier_magnus_illusion"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].alpha = 180
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {
	{
		0,
		v(0, 0)
	},
	{
		fts(6),
		v(0, 0)
	}
}
tt.tween.remove = false
tt.tween.run_once = true
tt.ui.click_rect = r(-13, -5, 26, 32)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 15)
tt.unit.price = 0
tt.vis.bans = bor(F_LYCAN, F_SKELETON, F_CANNIBALIZE)
tt = RT("soldier_ingvar_ancestor", "soldier_militia")

AC(tt, "reinforcement", "melee")

image_y = 60
image_x = 72
anchor_y = 0.17
tt.health.armor = 0.25
tt.health.hp_max = nil
tt.health_bar.offset = v(0, 46)
tt.health.dead_lifetime = fts(30)
tt.info.portrait = IS_PHONE and "portraits_hero_0011" or "info_portraits_hero_0011"
tt.info.fn = scripts.soldier_mercenary.get_info
tt.info.i18n_key = "HERO_VIKING_ANCESTOR"
tt.info.random_name_format = nil
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.remove = scripts.soldier_reinforcement.remove
tt.main_script.update = scripts.soldier_reinforcement.update
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.range = 128
tt.motion.max_speed = 2.3 * FPS
tt.reinforcement.duration = 10
tt.reinforcement.fade = nil
tt.regen.cooldown = 1
tt.render.sprites[1].prefix = "soldier_ingvar_ancestor"
tt.ui.click_rect = r(-13, 0, 26, 30)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 15)
tt.unit.price = 0
tt.vis.bans = bor(F_LYCAN, F_SKELETON, F_CANNIBALIZE)
tt = RT("hero_gerald", "hero")

AC(tt, "melee", "timed_attacks", "dodge")

anchor_y = 0.12
anchor_x = 0.5
image_y = 110
image_x = 92
tt.hero.fixed_stat_attack = 6
tt.hero.fixed_stat_health = 8
tt.hero.fixed_stat_range = 0
tt.hero.fixed_stat_speed = 5
tt.hero.level_stats.armor = {
	0.3,
	0.3,
	0.4,
	0.4,
	0.5,
	0.5,
	0.6,
	0.6,
	0.7,
	0.8
}
tt.hero.level_stats.hp_max = {
	400,
	420,
	440,
	460,
	480,
	500,
	520,
	540,
	560,
	580
}
tt.hero.level_stats.melee_damage_max = {
	18,
	20,
	23,
	25,
	28,
	30,
	33,
	35,
	38,
	40
}
tt.hero.level_stats.melee_damage_min = {
	11,
	12,
	14,
	15,
	17,
	18,
	20,
	21,
	23,
	24
}
tt.hero.level_stats.regen_health = {
	100,
	105,
	110,
	115,
	120,
	125,
	130,
	135,
	140,
	145
}
tt.hero.skills.block_counter = CC("hero_skill")
tt.hero.skills.block_counter.xp_level_steps = {
	[10.0] = 3,
	[4.0] = 1,
	[7.0] = 2
}
tt.hero.skills.block_counter.xp_gain = {
	100,
	200,
	300
}
tt.hero.skills.courage = CC("hero_skill")
tt.hero.skills.courage.xp_level_steps = {
	nil,
	1,
	nil,
	nil,
	2,
	nil,
	nil,
	3
}
tt.hero.skills.courage.xp_gain = {
	50,
	100,
	150
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 36)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = scripts.hero_gerald.level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.fn = scripts.hero_basic.get_info_melee
tt.info.hero_portrait = IS_PHONE and "hero_portraits_0002" or "heroPortrait_portraits_0002"
tt.info.i18n_key = "HERO_PALADIN"
tt.info.portrait = IS_PHONE and "portraits_hero_0002" or "info_portraits_hero_0005"
tt.main_script.update = scripts.hero_gerald.update
tt.motion.max_speed = 2.2 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(0.5, 0.12)
tt.render.sprites[1].prefix = "hero_gerald"
tt.soldier.melee_slot_offset = v(5, 0)
tt.sound_events.change_rally_point = "HeroPaladinTaunt"
tt.sound_events.death = "HeroPaladinDeath"
tt.sound_events.hero_room_select = "HeroPaladinTauntSelect"
tt.sound_events.insert = "HeroPaladinTauntIntro"
tt.sound_events.respawn = "HeroPaladinTauntIntro"
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 20)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].xp_gain_factor = 3
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.range = 65
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].animation = "courage"
tt.timed_attacks.list[1].cooldown = 6 + fts(55)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].min_count = 2
tt.timed_attacks.list[1].mod = "mod_gerald_courage"
tt.timed_attacks.list[1].range = 90
tt.timed_attacks.list[1].shoot_time = fts(17)
tt.timed_attacks.list[1].sound = "HeroPaladinValor"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(3)
}
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_MOD)
tt.timed_attacks.list[1].vis_bans = bor(F_HERO)
tt.dodge.animation = "counter"
tt.dodge.can_dodge = scripts.hero_gerald.fn_can_dodge
tt.dodge.chance = 0
tt.dodge.chance_base = 0
tt.dodge.chance_inc = 0.2
tt.dodge.time_before_hit = fts(4)
tt.dodge.low_chance_factor = 0.3333333333333333
tt.dodge.counter_attack = E:clone_c("melee_attack")
tt.dodge.counter_attack.animation = "counter"
tt.dodge.counter_attack.damage_type = bor(DAMAGE_TRUE, DAMAGE_NO_DODGE)
tt.dodge.counter_attack.reflected_damage_factor = 0.5
tt.dodge.counter_attack.reflected_damage_factor_inc = 0.5
tt.dodge.counter_attack.hit_time = fts(5)
tt.dodge.counter_attack.sound = "HeroPaladinDeflect"
tt = RT("hero_alleria", "hero")

AC(tt, "melee", "ranged", "timed_attacks")

anchor_y = 0.14
anchor_x = 0.5
image_y = 76
image_x = 60
tt.hero.fixed_stat_attack = 3
tt.hero.fixed_stat_health = 3
tt.hero.fixed_stat_range = 6
tt.hero.fixed_stat_speed = 6
tt.hero.level_stats.armor = {
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	2
}
tt.hero.level_stats.hp_max = {
	250,
	270,
	290,
	310,
	330,
	350,
	370,
	390,
	410,
	430*1.5
}
tt.hero.level_stats.melee_damage_max = {
	4 * 5,
	6 * 5,
	8 * 5,
	11 * 5,
	13 * 5,
	16 * 5,
	18 * 5,
	20 * 5,
	23 * 5,
	25 * 5
}
tt.hero.level_stats.melee_damage_min = {
	2 * 5,
	4 * 5,
	6 * 5,
	7 * 5,
	9 * 5,
	10 * 5,
	12 * 5,
	14 * 5,
	15 * 5,
	17 * 5
}
tt.hero.level_stats.ranged_damage_max = {
	12 * 5,
	14 * 5,
	15 * 5,
	17 * 5,
	18 * 5,
	20 * 5,
	21 * 5,
	23 * 5,
	24 * 5,
	26 * 8
}
tt.hero.level_stats.ranged_damage_min = {
	7 * 5,
	8 * 5,
	9 * 5,
	10 * 5,
	11 * 5,
	12 * 5,
	13 * 5,
	14 * 5,
	14 * 5,
	15 * 10
}
tt.hero.level_stats.regen_health = {
	63,
	68,
	73,
	78,
	83,
	88,
	93,
	98,
	103,
	108
}
tt.hero.skills.multishot = CC("hero_skill")
tt.hero.skills.multishot.count_base = 3
tt.hero.skills.multishot.count_inc = 2
tt.hero.skills.multishot.xp_level_steps = {
	nil,
	1,
	nil,
	nil,
	2,
	nil,
	nil,
	3
}
tt.hero.skills.multishot.xp_gain = {
	25,
	50,
	75
}
tt.hero.skills.callofwild = CC("hero_skill")
tt.hero.skills.callofwild.damage_max_base = 4
tt.hero.skills.callofwild.damage_min_base = 2
tt.hero.skills.callofwild.damage_inc = 4
tt.hero.skills.callofwild.hp_base = 0
tt.hero.skills.callofwild.hp_inc = 200
tt.hero.skills.callofwild.xp_gain = {
	50,
	100,
	150
}
tt.hero.skills.callofwild.xp_level_steps = {
	[10.0] = 3,
	[4.0] = 1,
	[7.0] = 2
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 33)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = scripts.hero_alleria.level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.damage_icon = "arrow"
tt.info.hero_portrait = IS_PHONE and "hero_portraits_0004" or "heroPortrait_portraits_0004"
tt.info.fn = scripts.hero_basic.get_info_ranged
tt.info.i18n_key = "HERO_ARCHER"
tt.info.portrait = IS_PHONE and "portraits_hero_0004" or "info_portraits_hero_0001"
tt.main_script.update = scripts.hero_alleria.update
tt.motion.max_speed = 6 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(0.5, 0.14)
tt.render.sprites[1].prefix = "hero_alleria"
tt.soldier.melee_slot_offset = v(4, 0)
tt.sound_events.change_rally_point = "HeroArcherTaunt"
tt.sound_events.death = "HeroArcherDeath"
tt.sound_events.hero_room_select = "HeroArcherTauntSelect"
tt.sound_events.insert = "HeroArcherTauntIntro"
tt.sound_events.respawn = "HeroArcherTauntIntro"
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 15)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 2.5
tt.melee.range = 45
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].bullet = "arrow_hero_alleria"
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 12)
}
tt.ranged.attacks[1].max_range = 150*2
tt.ranged.attacks[1].min_range = 45
tt.ranged.attacks[1].shoot_time = fts(6)
tt.ranged.attacks[1].cooldown = 0.1
tt.ranged.attacks[2] = E:clone_c("bullet_attack")
tt.ranged.attacks[2].animation = "multishot"
tt.ranged.attacks[2].bullet = "arrow_multishot_hero_alleria"
tt.ranged.attacks[2].bullet_start_offset = {
	v(0, 12)
}
tt.ranged.attacks[2].cooldown = 1.5 + fts(29)
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].max_range = 150*2
tt.ranged.attacks[2].min_range = 45
tt.ranged.attacks[2].node_prediction = fts(13)
tt.ranged.attacks[2].shoot_time = fts(13)
tt.ranged.attacks[2].sound = "HeroArcherShoot"
tt.ranged.attacks[2].xp_from_skill = "multishot"
tt.timed_attacks.list[1] = E:clone_c("spawn_attack")
tt.timed_attacks.list[1].animation = "callofwild"
tt.timed_attacks.list[1].cooldown = 20
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].entity = "soldier_alleria_wildcat"
tt.timed_attacks.list[1].pet = nil
tt.timed_attacks.list[1].sound = "HeroArcherSummon"
tt.timed_attacks.list[1].spawn_time = fts(17)
tt.timed_attacks.list[1].min_range = 30
tt.timed_attacks.list[1].max_range = 50
tt = RT("hero_bolin", "hero")

AC(tt, "melee", "timed_attacks")

anchor_y = 0.24
anchor_x = 0.5
image_y = 82
image_x = 92
tt.hero.fixed_stat_attack = 5
tt.hero.fixed_stat_health = 6
tt.hero.fixed_stat_range = 5
tt.hero.fixed_stat_speed = 4
tt.hero.level_stats.armor = {
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0
}
tt.hero.level_stats.hp_max = {
	400,
	430,
	460,
	490,
	520,
	550,
	580,
	610,
	640,
	670
}
tt.hero.level_stats.melee_damage_max = {
	15,
	18,
	20,
	23,
	25,
	28,
	30,
	33,
	35,
	38
}
tt.hero.level_stats.melee_damage_min = {
	9,
	11,
	12,
	14,
	15,
	17,
	18,
	20,
	21,
	23
}
tt.hero.level_stats.ranged_damage_max = {
	15,
	18,
	20,
	23,
	25,
	28,
	30,
	33,
	35,
	38
}
tt.hero.level_stats.ranged_damage_min = {
	9,
	11,
	12,
	14,
	15,
	17,
	18,
	20,
	21,
	23
}
tt.hero.level_stats.regen_health = {
	100,
	108,
	115,
	123,
	130,
	138,
	145,
	153,
	160,
	168
}
tt.hero.skills.mines = CC("hero_skill")
tt.hero.skills.mines.xp_level_steps = {
	nil,
	1,
	nil,
	nil,
	2,
	nil,
	nil,
	3
}
tt.hero.skills.mines.xp_gain = {
	25,
	50,
	75
}
tt.hero.skills.mines.damage_min = {
	30,
	60,
	90
}
tt.hero.skills.mines.damage_max = {
	60,
	90,
	120
}
tt.hero.skills.tar = CC("hero_skill")
tt.hero.skills.tar.duration = {
	4,
	6,
	8
}
tt.hero.skills.tar.xp_level_steps = {
	[10.0] = 3,
	[4.0] = 1,
	[7.0] = 2
}
tt.hero.skills.tar.xp_gain = {
	50,
	100,
	150
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 43)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = scripts.hero_bolin.level_up
tt.hero.tombstone_show_time = fts(60)
tt.info.damage_icon = "shot"
tt.info.hero_portrait = IS_PHONE and "hero_portraits_0003" or "heroPortrait_portraits_0003"
tt.info.fn = scripts.hero_bolin.get_info
tt.info.i18n_key = "HERO_RIFLEMAN"
tt.info.portrait = IS_PHONE and "portraits_hero_0003" or "info_portraits_hero_0002"
tt.melee.range = 65
tt.main_script.update = scripts.hero_bolin.update
tt.motion.max_speed = 2 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(0.5, 0.24)
tt.render.sprites[1].prefix = "hero_bolin"
tt.render.sprites[1].angles.shoot = {
	"shootRightLeft",
	"shootUp",
	"shootDown"
}
tt.render.sprites[1].angles.shootAim = {
	"shootAimRightLeft",
	"shootAimUp",
	"shootAimDown"
}
tt.soldier.melee_slot_offset = v(5, 0)
tt.sound_events.change_rally_point = "HeroRiflemanTaunt"
tt.sound_events.death = "HeroRiflemanDeath"
tt.sound_events.hero_room_select = "HeroRiflemanTauntSelect"
tt.sound_events.insert = "HeroRiflemanTauntIntro"
tt.sound_events.respawn = "HeroRiflemanTauntIntro"
tt.ui.click_rect = r(-15, -5, 30, 35)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 15)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.attacks[1].xp_gain_factor = 3
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].bullet = "shotgun_bolin"
tt.timed_attacks.list[1].aim_animation = "shootAim"
tt.timed_attacks.list[1].shoot_animation = "shoot"
tt.timed_attacks.list[1].bullet_start_offset = {
	v(0, 20),
	v(0, 20),
	v(0, 20)
}
tt.timed_attacks.list[1].cooldown = 2
tt.timed_attacks.list[1].shoot_times = {
	fts(10),
	fts(12),
	fts(12)
}
tt.timed_attacks.list[1].max_shoots = 3
tt.timed_attacks.list[1].min_range = 50
tt.timed_attacks.list[1].max_range = 180
tt.timed_attacks.list[1].shoot_time = fts(2)
tt.timed_attacks.list[1].vis_bans = 0
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[1].xp_gain_factor = 3
tt.timed_attacks.list[2] = CC("bullet_attack")
tt.timed_attacks.list[2].bullet = "bomb_tar_bolin"
tt.timed_attacks.list[2].bullet_start_offset = v(0, 30)
tt.timed_attacks.list[2].cooldown = 14 + fts(27)
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].min_range = 100
tt.timed_attacks.list[2].max_range = 200
tt.timed_attacks.list[2].shoot_time = fts(13)
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[3] = CC("bullet_attack")
tt.timed_attacks.list[3].bullet = "bomb_mine_bolin"
tt.timed_attacks.list[3].bullet_start_offset = v(0, 12)
tt.timed_attacks.list[3].count = 5
tt.timed_attacks.list[3].cooldown = 6 + fts(19)
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].max_range = 60
tt.timed_attacks.list[3].shoot_time = fts(3)
tt.timed_attacks.list[3].node_offset = {
	-12,
	12
}
tt = RT("hero_magnus", "hero")

AC(tt, "melee", "ranged", "timed_attacks", "teleport")

anchor_y = 0.14
anchor_x = 0.5
image_y = 76
image_x = 60
tt.hero.fixed_stat_attack = 2
tt.hero.fixed_stat_health = 2
tt.hero.fixed_stat_range = 8
tt.hero.fixed_stat_speed = 8
tt.hero.level_stats.armor = {
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0
}
tt.hero.level_stats.hp_max = {
	170,
	190,
	210,
	230,
	250,
	270,
	290,
	310,
	330,
	350
}
tt.hero.level_stats.melee_damage_max = {
	2,
	4,
	5,
	6,
	7,
	8,
	10,
	11,
	12,
	13
}
tt.hero.level_stats.melee_damage_min = {
	1,
	2,
	2,
	3,
	4,
	5,
	6,
	6,
	7,
	8
}
tt.hero.level_stats.ranged_damage_max = {
	27,
	32,
	36,
	41,
	45,
	50,
	54,
	59,
	63,
	68
}
tt.hero.level_stats.ranged_damage_min = {
	9,
	11,
	12,
	14,
	15,
	17,
	18,
	20,
	21,
	23
}
tt.hero.level_stats.regen_health = {
	43,
	48,
	53,
	58,
	63,
	68,
	73,
	78,
	83,
	88
}
tt.hero.skills.mirage = CC("hero_skill")
tt.hero.skills.mirage.count = {
	1,
	2,
	3
}
tt.hero.skills.mirage.health_factor = 0.3
tt.hero.skills.mirage.damage_factor = 0.2
tt.hero.skills.mirage.xp_level_steps = {
	nil,
	1,
	nil,
	nil,
	2,
	nil,
	nil,
	3
}
tt.hero.skills.mirage.xp_gain = {
	50,
	100,
	150
}
tt.hero.skills.arcane_rain = CC("hero_skill")
tt.hero.skills.arcane_rain.count = {
	6,
	12,
	18
}
tt.hero.skills.arcane_rain.damage = {
	20,
	20,
	20
}
tt.hero.skills.arcane_rain.xp_level_steps = {
	[10.0] = 3,
	[4.0] = 1,
	[7.0] = 2
}
tt.hero.skills.arcane_rain.xp_gain = {
	50,
	100,
	150
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 33)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = scripts.hero_magnus.level_up
tt.hero.tombstone_show_time = fts(60)
tt.info.hero_portrait = IS_PHONE and "hero_portraits_0005" or "heroPortrait_portraits_0005"
tt.info.fn = scripts.hero_basic.get_info_ranged
tt.info.i18n_key = "HERO_MAGE"
tt.info.portrait = IS_PHONE and "portraits_hero_0005" or "info_portraits_hero_0004"
tt.main_script.update = scripts.hero_magnus.update
tt.motion.max_speed = 1.2 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "hero_magnus"
tt.soldier.melee_slot_offset = v(4, 0)
tt.sound_events.death = "HeroMageDeath"
tt.sound_events.insert = "HeroMageTauntIntro"
tt.sound_events.respawn = "HeroMageTauntIntro"
tt.sound_events.change_rally_point = "HeroMageTaunt"
tt.sound_events.hero_room_select = "HeroMageTauntSelect"
tt.teleport.min_distance = 100
tt.teleport.delay = 0
tt.teleport.sound = "TeleporthSound"
tt.ui.click_rect = r(-13, -5, 26, 32)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 15)
tt.melee.range = 45
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].xp_gain_factor = 2.1
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "bolt_magnus"
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 23)
}
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].shoot_time = fts(18)
tt.ranged.attacks[1].cooldown = fts(33)
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].animation = "mirage"
tt.timed_attacks.list[1].cooldown = 10 + fts(29)
tt.timed_attacks.list[1].cast_time = fts(12)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].entity = "soldier_magnus_illusion"
tt.timed_attacks.list[1].entity_rotations = {
	{
		d2r(0)
	},
	{
		d2r(0),
		d2r(180)
	},
	{
		d2r(0),
		d2r(120),
		d2r(240)
	}
}
tt.timed_attacks.list[1].sound = "HeroMageShadows"
tt.timed_attacks.list[1].spawn_time = fts(19)
tt.timed_attacks.list[1].initial_rally = v(0, 30)
tt.timed_attacks.list[1].initial_pos = v(0, 33)
tt.timed_attacks.list[1].radius = 30
tt.timed_attacks.list[1].spawn_time = fts(19)
tt.timed_attacks.list[1].spawn_time = fts(19)
tt.timed_attacks.list[1].xp_from_skill = "mirage"
tt.timed_attacks.list[2] = CC("spawn_attack")
tt.timed_attacks.list[2].animation = "arcaneRain"
tt.timed_attacks.list[2].entity = "magnus_arcane_rain_controller"
tt.timed_attacks.list[2].cooldown = 14 + fts(25)
tt.timed_attacks.list[2].cast_time = fts(15)
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].max_range = 200
tt.timed_attacks.list[2].min_range = 50
tt.timed_attacks.list[2].sound = "HeroMageRainCharge"
tt.timed_attacks.list[2].vis_bans = bor(F_FRIEND, F_FLYING)
tt.timed_attacks.list[2].vis_flags = F_RANGED
tt.timed_attacks.list[2].xp_from_skill = "arcane_rain"
tt = RT("hero_ignus", "hero")

AC(tt, "melee", "timed_attacks")

anchor_y = 0.1
anchor_x = 0.5
image_y = 72
image_x = 60
tt.hero.fixed_stat_attack = 8
tt.hero.fixed_stat_health = 6
tt.hero.fixed_stat_range = 0
tt.hero.fixed_stat_speed = 6
tt.hero.level_stats.armor = {
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0
}
tt.hero.level_stats.hp_max = {
	400,
	430,
	460,
	490,
	520,
	550,
	580,
	610,
	640,
	670
}
tt.hero.level_stats.melee_damage_max = {
	30,
	33,
	35,
	38,
	40,
	43,
	45,
	48,
	50,
	53
}
tt.hero.level_stats.melee_damage_min = {
	18,
	20,
	21,
	23,
	24,
	26,
	27,
	29,
	30,
	32
}
tt.hero.level_stats.regen_health = {
	100,
	108,
	115,
	123,
	130,
	138,
	145,
	153,
	160,
	168
}
tt.hero.skills.flaming_frenzy = CC("hero_skill")
tt.hero.skills.flaming_frenzy.damage_max = {
	30,
	50,
	70
}
tt.hero.skills.flaming_frenzy.damage_min = {
	20,
	40,
	60
}
tt.hero.skills.flaming_frenzy.xp_level_steps = {
	[10.0] = 3,
	[4.0] = 1,
	[7.0] = 2
}
tt.hero.skills.flaming_frenzy.xp_gain = {
	100,
	200,
	300
}
tt.hero.skills.surge_of_flame = CC("hero_skill")
tt.hero.skills.surge_of_flame.damage_max = {
	20,
	30,
	40
}
tt.hero.skills.surge_of_flame.damage_min = {
	10,
	20,
	30
}
tt.hero.skills.surge_of_flame.xp_level_steps = {
	nil,
	1,
	nil,
	nil,
	2,
	nil,
	nil,
	3
}
tt.hero.skills.surge_of_flame.xp_gain = {
	50,
	100,
	150
}
tt.health.dead_lifetime = 12
tt.health_bar.offset = v(0, 41)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = scripts.hero_ignus.level_up
tt.hero.tombstone_show_time = fts(60)
tt.info.hero_portrait = IS_PHONE and "hero_portraits_0006" or "heroPortrait_portraits_0006"
tt.info.fn = scripts.hero_basic.get_info_melee
tt.info.i18n_key = "HERO_FIRE"
tt.info.portrait = IS_PHONE and "portraits_hero_0006" or "info_portraits_hero_0003"
tt.main_script.update = scripts.hero_ignus.update
tt.motion.max_speed = 3 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "hero_ignus"
tt.run_particles_name = "ps_ignus_run"
tt.particles_aura = "aura_ignus_idle"
tt.soldier.melee_slot_offset = v(6, 0)
tt.sound_events.change_rally_point = "HeroRainOfFireTaunt"
tt.sound_events.death = "HeroRainOfFireDeath"
tt.sound_events.hero_room_select = "HeroRainOfFireTauntSelect"
tt.sound_events.insert = "HeroRainOfFireTauntIntro"
tt.sound_events.respawn = "HeroRainOfFireTauntIntro"
tt.unit.hit_offset = v(0, 19)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 20)
tt.vis.bans = bor(tt.vis.bans, F_BURN)
tt.melee.range = 60
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].xp_gain_factor = 2
tt.melee.attacks[1].sound_hit = "HeroReinforcementHit"
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "flamingFrenzy"
tt.timed_attacks.list[1].cast_time = fts(8)
tt.timed_attacks.list[1].chance = 0.25
tt.timed_attacks.list[1].cooldown = 4 + fts(24)
tt.timed_attacks.list[1].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[1].decal = "decal_ignus_flaming"
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].heal_factor = 0.2
tt.timed_attacks.list[1].hit_fx = "fx_ignus_burn"
tt.timed_attacks.list[1].max_range = 90
tt.timed_attacks.list[1].sound = "HeroRainOfFireArea"
tt.timed_attacks.list[1].vis_bans = bor(F_FRIEND)
tt.timed_attacks.list[1].vis_flags = bor(F_AREA)
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animations = {
	"surgeOfFlame",
	"surgeOfFlame_end"
}
tt.timed_attacks.list[2].aura = "aura_ignus_surge_of_flame"
tt.timed_attacks.list[2].cooldown = 4
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].nodes_margin = 8
tt.timed_attacks.list[2].min_range = 40
tt.timed_attacks.list[2].max_range = 130
tt.timed_attacks.list[2].speed_factor = 3.3333333333333335
tt.timed_attacks.list[2].sound = "HeroRainOfFireFireball1"
tt.timed_attacks.list[2].sound_end = "HeroRainOfFireFireball2"
tt.timed_attacks.list[2].vis_bans = bor(F_FRIEND)
tt.timed_attacks.list[2].vis_flags = bor(F_ENEMY, F_BLOCK)
tt = RT("hero_malik", "hero")

AC(tt, "melee")

anchor_y = 0.1
anchor_x = 0.5
image_y = 100
image_x = 96
tt.hero.fixed_stat_attack = 7
tt.hero.fixed_stat_health = 8
tt.hero.fixed_stat_range = 0
tt.hero.fixed_stat_speed = 4
tt.hero.level_stats.armor = {
	0,
	0.1,
	0.1,
	0.2,
	0.2,
	0.3,
	0.3,
	0.4,
	0.4,
	0.5
}
tt.hero.level_stats.hp_max = {
	450,
	480,
	510,
	540,
	570,
	600,
	630,
	660,
	690,
	720
}
tt.hero.level_stats.melee_damage_max = {
	22,
	24,
	26,
	29,
	31,
	34,
	36,
	38,
	41,
	43
}
tt.hero.level_stats.melee_damage_min = {
	14,
	16,
	18,
	19,
	21,
	22,
	24,
	26,
	27,
	29
}
tt.hero.level_stats.regen_health = {
	113,
	120,
	128,
	135,
	143,
	150,
	158,
	165,
	173,
	180
}
tt.hero.skills.smash = CC("hero_skill")
tt.hero.skills.smash.damage_min = {
	20,
	40,
	60
}
tt.hero.skills.smash.damage_max = {
	40,
	60,
	80
}
tt.hero.skills.smash.xp_level_steps = {
	nil,
	1,
	nil,
	nil,
	2,
	nil,
	nil,
	3
}
tt.hero.skills.smash.xp_gain = {
	50,
	100,
	150
}
tt.hero.skills.fissure = CC("hero_skill")
tt.hero.skills.fissure.damage_min = {
	10,
	20,
	30
}
tt.hero.skills.fissure.damage_max = {
	30,
	40,
	50
}
tt.hero.skills.fissure.xp_level_steps = {
	[10.0] = 3,
	[4.0] = 1,
	[7.0] = 2
}
tt.hero.skills.fissure.xp_gain = {
	50,
	100,
	150
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 38)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = scripts.hero_malik.level_up
tt.hero.tombstone_show_time = fts(60)
tt.info.hero_portrait = IS_PHONE and "hero_portraits_0001" or "heroPortrait_portraits_0001"
tt.info.i18n_key = "HERO_REINFORCEMENT"
tt.info.fn = scripts.hero_basic.get_info_melee
tt.info.portrait = IS_PHONE and "portraits_hero_0001" or "info_portraits_hero_0006"
tt.main_script.update = scripts.hero_malik.update
tt.motion.max_speed = 2 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(0.5, 0.1)
tt.render.sprites[1].prefix = "hero_malik"
tt.soldier.melee_slot_offset = v(5, 0)
tt.sound_events.change_rally_point = "HeroReinforcementTaunt"
tt.sound_events.death = "HeroReinforcementDeath"
tt.sound_events.hero_room_select = "HeroReinforcementTauntSelect"
tt.sound_events.insert = "HeroReinforcementTauntIntro"
tt.sound_events.respawn = "HeroReinforcementTauntIntro"
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 20)
tt.melee.range = 65
tt.melee.cooldown = 1
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].xp_gain_factor = 1.9549999999999998
tt.melee.attacks[1].sound_hit = "HeroReinforcementHit"
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[3] = CC("area_attack")
tt.melee.attacks[3].animation = "smash"
tt.melee.attacks[3].cooldown = 6 + fts(28)
tt.melee.attacks[3].damage_max = nil
tt.melee.attacks[3].damage_min = nil
tt.melee.attacks[3].damage_radius = 60
tt.melee.attacks[3].damage_type = DAMAGE_TRUE
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].hit_decal = "decal_bomb_crater"
tt.melee.attacks[3].hit_fx = "decal_malik_ring"
tt.melee.attacks[3].hit_time = fts(14)
tt.melee.attacks[3].hit_offset = v(22, 0)
tt.melee.attacks[3].min_count = 3
tt.melee.attacks[3].sound = "HeroReinforcementSpecial"
tt.melee.attacks[3].xp_from_skill = "smash"
tt.melee.attacks[4] = CC("area_attack")
tt.melee.attacks[4].animation = "fissure"
tt.melee.attacks[4].cooldown = 14 + fts(37)
tt.melee.attacks[4].damage_max = 0
tt.melee.attacks[4].damage_min = 0
tt.melee.attacks[4].damage_radius = 40
tt.melee.attacks[4].damage_type = DAMAGE_NONE
tt.melee.attacks[4].disabled = true
tt.melee.attacks[4].hit_aura = "aura_malik_fissure"
tt.melee.attacks[4].hit_offset = v(22, 0)
tt.melee.attacks[4].hit_time = fts(17)
tt.melee.attacks[4].sound = "HeroReinforcementJump"
tt.melee.attacks[4].xp_from_skill = "fissure"
tt = RT("hero_denas", "hero")

AC(tt, "melee", "ranged", "timed_attacks")

anchor_y = 0.26
anchor_x = 0.5
image_y = 108
image_x = 152
tt.hero.fixed_stat_attack = 6
tt.hero.fixed_stat_health = 5
tt.hero.fixed_stat_range = 6
tt.hero.fixed_stat_speed = 3
tt.hero.level_stats.armor = {
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0
}
tt.hero.level_stats.hp_max = {
	300,
	320,
	340,
	360,
	380,
	400,
	420,
	440,
	460,
	480
}
tt.hero.level_stats.melee_damage_max = {
	19,
	23,
	28,
	33,
	38,
	42,
	47,
	52,
	56,
	61
}
tt.hero.level_stats.melee_damage_min = {
	11,
	14,
	17,
	20,
	23,
	25,
	28,
	31,
	34,
	37
}
tt.hero.level_stats.ranged_damage_max = {
	19,
	23,
	28,
	33,
	38,
	42,
	47,
	52,
	56,
	61
}
tt.hero.level_stats.ranged_damage_min = {
	11,
	14,
	17,
	20,
	23,
	25,
	28,
	31,
	34,
	37
}
tt.hero.level_stats.regen_health = {
	75,
	80,
	85,
	90,
	95,
	100,
	105,
	110,
	115,
	120
}
tt.hero.skills.tower_buff = CC("hero_skill")
tt.hero.skills.tower_buff.duration = {
	5,
	8,
	11
}
tt.hero.skills.tower_buff.xp_level_steps = {
	nil,
	1,
	nil,
	nil,
	2,
	nil,
	nil,
	3
}
tt.hero.skills.tower_buff.xp_gain = {
	50,
	100,
	150
}
tt.hero.skills.catapult = CC("hero_skill")
tt.hero.skills.catapult.count = {
	3,
	5,
	7
}
tt.hero.skills.catapult.damage_min = {
	10,
	20,
	30
}
tt.hero.skills.catapult.damage_max = {
	30,
	40,
	50
}
tt.hero.skills.catapult.xp_level_steps = {
	[10.0] = 3,
	[4.0] = 1,
	[7.0] = 2
}
tt.hero.skills.catapult.xp_gain = {
	100,
	200,
	300
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 60)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = scripts.hero_denas.level_up
tt.hero.tombstone_show_time = fts(60)
tt.info.hero_portrait = IS_PHONE and "hero_portraits_0007" or "heroPortrait_portraits_0007"
tt.info.i18n_key = "HERO_DENAS"
tt.info.fn = scripts.hero_basic.get_info_ranged
tt.info.portrait = IS_PHONE and "portraits_hero_0008" or "info_portraits_hero_0008"
tt.main_script.update = scripts.hero_denas.update
tt.motion.max_speed = 2 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "hero_denas"
tt.soldier.melee_slot_offset = v(22, 0)
tt.sound_events.change_rally_point = "HeroDenasTaunt"
tt.sound_events.death = "HeroDenasDeath"
tt.sound_events.hero_room_select = "HeroDenasTauntSelect"
tt.sound_events.insert = "HeroRainOfFireTauntIntro"
tt.sound_events.respawn = "HeroRainOfFireTauntIntro"
tt.ui.click_rect = r(-22, 15, 44, 32)
tt.unit.hit_offset = v(0, 31)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 30)
tt.melee.range = 45
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animations = {
	"attack",
	"attackBarrell",
	"attackChicken",
	"attackBottle"
}
tt.ranged.attacks[1].bullet = "projectile_denas"
tt.ranged.attacks[1].bullets = {
	"projectile_denas",
	"projectile_denas_barrell",
	"projectile_denas_chicken",
	"projectile_denas_bottle"
}
tt.ranged.attacks[1].bullet_start_offset = {
	v(10, 36)
}
tt.ranged.attacks[1].cooldown = fts(19)
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 45
tt.ranged.attacks[1].node_prediction = fts(10)
tt.ranged.attacks[1].shoot_time = fts(7)
tt.timed_attacks.list[1] = table.deepclone(tt.ranged.attacks[1])
tt.timed_attacks.list[1].bullets = {
	"projectile_denas_melee",
	"projectile_denas_melee_barrell",
	"projectile_denas_melee_chicken",
	"projectile_denas_melee_bottle"
}
tt.timed_attacks.list[1].cooldown = 1.5
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].animation = "buffTowers"
tt.timed_attacks.list[2].cooldown = 10 + fts(51)
tt.timed_attacks.list[2].cast_time = fts(13)
tt.timed_attacks.list[2].curse_time = fts(2)
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].max_range = 165
tt.timed_attacks.list[2].min_range = 0
tt.timed_attacks.list[2].mod = "mod_denas_tower"
tt.timed_attacks.list[2].aura = "denas_buff_aura"
tt.timed_attacks.list[2].sound = "HeroDenasBuff"
tt.timed_attacks.list[2].xp_from_skill = "buff_towers"
tt.timed_attacks.list[3] = CC("spawn_attack")
tt.timed_attacks.list[3].animation = "catapult"
tt.timed_attacks.list[3].entity = "denas_catapult_controller"
tt.timed_attacks.list[3].cooldown = 10 + fts(40)
tt.timed_attacks.list[3].cast_time = fts(7)
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].max_range = 165
tt.timed_attacks.list[3].min_range = 50
tt.timed_attacks.list[3].sound = "HeroDenasAttack"
tt.timed_attacks.list[3].vis_bans = bor(F_FRIEND, F_FLYING)
tt.timed_attacks.list[3].vis_flags = F_RANGED
tt.timed_attacks.list[3].xp_from_skill = "catapult"
tt = RT("hero_ingvar", "hero")

AC(tt, "melee", "timed_attacks", "auras")

anchor_y = 0.19
anchor_x = 0.5
image_y = 116
image_x = 142
tt.hero.fixed_stat_attack = 8
tt.hero.fixed_stat_health = 8
tt.hero.fixed_stat_range = 0
tt.hero.fixed_stat_speed = 5
tt.hero.level_stats.armor = {
	0.1,
	0.1,
	0.15,
	0.15,
	0.2,
	0.2,
	0.25,
	0.25,
	0.3,
	0.4
}
tt.hero.level_stats.hp_max = {
	430,
	460,
	490,
	520,
	550,
	580,
	610,
	640,
	670,
	670
}
tt.hero.level_stats.melee_damage_max = {
	38,
	41,
	45,
	49,
	53,
	56,
	60,
	64,
	68,
	71
}
tt.hero.level_stats.melee_damage_min = {
	23,
	25,
	27,
	29,
	32,
	34,
	36,
	38,
	41,
	43
}
tt.hero.level_stats.regen_health = {
	108,
	115,
	123,
	130,
	138,
	145,
	153,
	160,
	168,
	175
}
tt.hero.skills.ancestors_call = CC("hero_skill")
tt.hero.skills.ancestors_call.count = {
	1,
	2,
	3
}
tt.hero.skills.ancestors_call.hp_max = {
	100,
	150,
	200
}
tt.hero.skills.ancestors_call.damage_min = {
	2,
	4,
	6
}
tt.hero.skills.ancestors_call.damage_max = {
	6,
	8,
	10
}
tt.hero.skills.ancestors_call.xp_level_steps = {
	nil,
	1,
	nil,
	nil,
	2,
	nil,
	nil,
	3
}
tt.hero.skills.ancestors_call.xp_gain = {
	100,
	200,
	300
}
tt.hero.skills.bear = CC("hero_skill")
tt.hero.skills.bear.damage_min = {
	20,
	30,
	40
}
tt.hero.skills.bear.damage_max = {
	40,
	50,
	60
}
tt.hero.skills.bear.duration = {
	10,
	12,
	14
}
tt.hero.skills.bear.xp_level_steps = {
	[10.0] = 3,
	[4.0] = 1,
	[7.0] = 2
}
tt.hero.skills.bear.xp_gain = {
	100,
	200,
	300
}
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_ingvar_bear_regenerate"
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, ady(68))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = scripts.hero_ingvar.level_up
tt.hero.tombstone_show_time = fts(60)
tt.info.hero_portrait = IS_PHONE and "hero_portraits_0009" or "heroPortrait_portraits_0009"
tt.info.fn = scripts.hero_ingvar.get_info
tt.info.i18n_key = "HERO_VIKING"
tt.info.portrait = IS_PHONE and "portraits_hero_0010" or "info_portraits_hero_0010"
tt.main_script.update = scripts.hero_ingvar.update
tt.motion.max_speed = 2.5 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "hero_ingvar"
tt.soldier.melee_slot_offset = v(14, 0)
tt.sound_events.change_rally_point = "HeroVikingTaunt"
tt.sound_events.change_rally_point_viking = "HeroVikingTaunt"
tt.sound_events.change_rally_point_bear = "HeroVikingBearTransform"
tt.sound_events.death = "HeroVikingDeath"
tt.sound_events.hero_room_select = "HeroVikingTauntSelect"
tt.sound_events.insert = "HeroVikingTauntIntro"
tt.sound_events.respawn = "HeroVikingTauntIntro"
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 20)
tt.unit.hit_offset = v(0, 20)
tt.melee.range = 83.2
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "HeroVikingAttackHit"
tt.melee.attacks[1].hit_decal = "decal_ingvar_attack"
tt.melee.attacks[1].hit_offset = v(48, -1)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].xp_gain_factor = 2
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[2].hit_time = fts(15)
tt.melee.attacks[2].hit_offset = v(-25, 2)
tt.melee.attacks[3] = CC("melee_attack")
tt.melee.attacks[3].animations = {
	nil,
	"attack"
}
tt.melee.attacks[3].cooldown = 3
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].damage_min = nil
tt.melee.attacks[3].damage_max = nil
tt.melee.attacks[3].hit_times = {
	fts(10),
	fts(25),
	fts(41)
}
tt.melee.attacks[3].loopable = true
tt.melee.attacks[3].loops = 1
tt.melee.attacks[3].sound_hit = "HeroVikingAttackHit"
tt.melee.attacks[3].sound = "HeroVikingBearAttackStart"
tt.melee.attacks[3].vis_flags = F_BLOCK
tt.melee.attacks[3].xp_gain_factor = 2
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].animation = "ancestors"
tt.timed_attacks.list[1].cooldown = 14 + fts(40)
tt.timed_attacks.list[1].cast_time = fts(15)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].entity = "soldier_ingvar_ancestor"
tt.timed_attacks.list[1].sound = "HeroVikingCall"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(5)
}
tt.timed_attacks.list[1].nodes_offset = {
	4,
	8
}
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].cooldown = 10
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].duration = nil
tt.timed_attacks.list[2].transform_health_factor = 0.6
tt.timed_attacks.list[2].immune_to = bor(DAMAGE_BASE_TYPES, DAMAGE_MODIFIER)
tt.timed_attacks.list[2].sound = "HeroVikingBearTransform"
tt = RT("hero_elora", "hero")

AC(tt, "melee", "ranged", "timed_attacks")

anchor_y = 0.17
anchor_x = 0.5
tt.hero.fixed_stat_attack = 2
tt.hero.fixed_stat_health = 3
tt.hero.fixed_stat_range = 8
tt.hero.fixed_stat_speed = 7
tt.hero.level_stats.armor = {
	0.2,
	0.2,
	0.2,
	0.3,
	0.3,
	0.3,
	0.4,
	0.4,
	0.4,
	0.5
}
tt.hero.level_stats.hp_max = {
	270,
	290,
	310,
	330,
	350,
	370,
	390,
	410,
	430,
	450
}
tt.hero.level_stats.melee_damage_max = {
	2,
	4,
	6,
	8,
	11,
	13,
	16,
	18,
	20,
	23
}
tt.hero.level_stats.melee_damage_min = {
	1,
	2,
	4,
	6,
	7,
	9,
	10,
	12,
	14,
	15
}
tt.hero.level_stats.ranged_damage_max = {
	41,
	47,
	54,
	61,
	68,
	74,
	81,
	88,
	95,
	101
}
tt.hero.level_stats.ranged_damage_min = {
	14,
	16,
	18,
	20,
	23,
	25,
	27,
	29,
	32,
	34
}
tt.hero.level_stats.regen_health = {
	68,
	73,
	78,
	83,
	88,
	93,
	98,
	103,
	108,
	113
}
tt.hero.skills.chill = CC("hero_skill")
tt.hero.skills.chill.slow_factor = {
	0.4,
	0.30000000000000004,
	0.19999999999999996
}
tt.hero.skills.chill.max_range = {
	153.6,
	166.4,
	179.20000000000002
}
tt.hero.skills.chill.count = {
	6,
	8,
	10
}
tt.hero.skills.chill.xp_level_steps = {
	nil,
	1,
	nil,
	nil,
	2,
	nil,
	nil,
	3
}
tt.hero.skills.chill.xp_gain = {
	125,
	250,
	375
}
tt.hero.skills.ice_storm = CC("hero_skill")
tt.hero.skills.ice_storm.count = {
	3,
	5,
	8
}
tt.hero.skills.ice_storm.damage_max = {
	40,
	50,
	60
}
tt.hero.skills.ice_storm.damage_min = {
	20,
	20,
	30
}
tt.hero.skills.ice_storm.max_range = {
	153.6,
	166.4,
	179.20000000000002
}
tt.hero.skills.ice_storm.xp_level_steps = {
	[10.0] = 3,
	[4.0] = 1,
	[7.0] = 2
}
tt.hero.skills.ice_storm.xp_gain = {
	100,
	200,
	300
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 46)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = scripts.hero_elora.level_up
tt.hero.tombstone_show_time = fts(60)
tt.info.hero_portrait = IS_PHONE and "hero_portraits_0008" or "heroPortrait_portraits_0008"
tt.info.i18n_key = "HERO_FROST_SORCERER"
tt.info.fn = scripts.hero_basic.get_info_ranged
tt.info.portrait = IS_PHONE and "portraits_hero_0009" or "info_portraits_hero_0009"
tt.main_script.update = scripts.hero_elora.update
tt.motion.max_speed = 3 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(0.5, 0.17)
tt.render.sprites[1].prefix = "hero_elora"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "hero_elora_frostEffect"
tt.render.sprites[2].anchor = v(0.5, 0.1)
tt.render.sprites[2].hidden = true
tt.render.sprites[2].loop = true
tt.render.sprites[2].ignore_start = true
tt.run_particles_name = "ps_elora_run"
tt.soldier.melee_slot_offset = v(12, 0)
tt.sound_events.change_rally_point = "HeroFrostTaunt"
tt.sound_events.death = "HeroFrostDeath"
tt.sound_events.hero_room_select = "HeroFrostTauntSelect"
tt.sound_events.insert = "HeroFrostTauntIntro"
tt.sound_events.respawn = "HeroFrostTauntIntro"
tt.ui.click_rect = r(-15, -5, 30, 40)
tt.unit.mod_offset = v(0, 15)
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 2
tt.melee.attacks[1].damage_type = DAMAGE_MAGICAL
tt.melee.range = 45
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].cooldown = fts(54)
tt.ranged.attacks[1].bullet = "bolt_elora_freeze"
tt.ranged.attacks[1].bullet_start_offset = {
	v(18, 36)
}
tt.ranged.attacks[1].chance = 0.2
tt.ranged.attacks[1].filter_fn = scripts.hero_elora.freeze_filter_fn
tt.ranged.attacks[1].min_range = 23.04
tt.ranged.attacks[1].max_range = 166.4
tt.ranged.attacks[1].shoot_time = fts(19)
tt.ranged.attacks[1].shared_cooldown = true
tt.ranged.attacks[1].vis_bans = bor(F_BOSS)
tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
tt.ranged.attacks[1].xp_gain_factor = 2
tt.ranged.attacks[2] = table.deepclone(tt.ranged.attacks[1])
tt.ranged.attacks[2].bullet = "bolt_elora_slow"
tt.ranged.attacks[2].chance = 1
tt.ranged.attacks[2].filter_fn = nil
tt.ranged.attacks[2].vis_bans = 0
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "iceStorm"
tt.timed_attacks.list[1].bullet = "elora_ice_spike"
tt.timed_attacks.list[1].cast_time = fts(24)
tt.timed_attacks.list[1].cooldown = 10 + fts(39)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].max_range = nil
tt.timed_attacks.list[1].min_range = 38.4
tt.timed_attacks.list[1].nodes_offset = 4
tt.timed_attacks.list[1].sound = "HeroFrostIceRainSummon"
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_FRIEND)
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].xp_from_skill = "ice_storm"
tt.timed_attacks.list[2] = CC("aura_attack")
tt.timed_attacks.list[2].animation = "chill"
tt.timed_attacks.list[2].bullet = "aura_chill_elora"
tt.timed_attacks.list[2].cast_time = fts(18)
tt.timed_attacks.list[2].cooldown = 8 + fts(28)
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].max_range = nil
tt.timed_attacks.list[2].min_range = 19.2
tt.timed_attacks.list[2].sound = "HeroFrostGroundFreeze"
tt.timed_attacks.list[2].step = 3
tt.timed_attacks.list[2].nodes_offset = 6
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING, F_FRIEND)
tt.timed_attacks.list[2].vis_flags = F_RANGED
tt.timed_attacks.list[2].xp_from_skill = "chill"
tt = RT("hero_oni", "hero")

AC(tt, "melee", "timed_attacks")

anchor_y = 0.14285714285714285
anchor_x = 0.5
image_y = 112
image_x = 128
tt.hero.fixed_stat_attack = 8
tt.hero.fixed_stat_health = 7
tt.hero.fixed_stat_range = 0
tt.hero.fixed_stat_speed = 6
tt.hero.level_stats.armor = {
	0.3,
	0.3,
	0.3,
	0.4,
	0.4,
	0.4,
	0.5,
	0.5,
	0.6,
	0.6
}
tt.hero.level_stats.hp_max = {
	425,
	450,
	475,
	500,
	525,
	550,
	575,
	600,
	625,
	650
}
tt.hero.level_stats.melee_damage_max = {
	41,
	45,
	49,
	53,
	56,
	60,
	64,
	68,
	71,
	75
}
tt.hero.level_stats.melee_damage_min = {
	14,
	15,
	16,
	18,
	19,
	20,
	21,
	23,
	24,
	25
}
tt.hero.level_stats.regen_health = {
	106,
	113,
	119,
	125,
	131,
	138,
	144,
	150,
	156,
	163
}
tt.hero.skills.death_strike = CC("hero_skill")
tt.hero.skills.death_strike.chance = {
	0.1,
	0.15,
	0.2
}
tt.hero.skills.death_strike.damage = {
	180,
	260,
	340
}
tt.hero.skills.death_strike.xp_level_steps = {
	[10.0] = 3,
	[4.0] = 1,
	[7.0] = 2
}
tt.hero.skills.death_strike.xp_gain = {
	50,
	100,
	150
}
tt.hero.skills.torment = CC("hero_skill")
tt.hero.skills.torment.min_damage = {
	50,
	80,
	110
}
tt.hero.skills.torment.max_damage = {
	80,
	110,
	140
}
tt.hero.skills.torment.xp_level_steps = {
	nil,
	1,
	nil,
	nil,
	2,
	nil,
	nil,
	3
}
tt.hero.skills.torment.xp_gain = {
	50,
	100,
	150
}
tt.health.dead_lifetime = 18
tt.health.on_damage = scripts.hero_oni.on_damage
tt.health_bar.offset = v(0, 50)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = scripts.hero_oni.level_up
tt.hero.tombstone_show_time = fts(150)
tt.info.fn = scripts.hero_basic.get_info_melee
tt.info.hero_portrait = IS_PHONE and "hero_portraits_0011" or "heroPortrait_portraits_0011"
tt.info.i18n_key = "HERO_SAMURAI"
tt.info.portrait = IS_PHONE and "portraits_hero_0013" or "info_portraits_hero_0013"
tt.melee.range = 65
tt.main_script.update = scripts.hero_oni.update
tt.motion.max_speed = 2.7 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].prefix = "hero_oni"
tt.render.sprites[1].anchor = v(0.5, 0.14285714285714285)
tt.soldier.melee_slot_offset = v(8, 0)
tt.sound_events.change_rally_point = "HeroSamuraiTaunt"
tt.sound_events.death = "HeroSamuraiDeath"
tt.sound_events.hero_room_select = "HeroSamuraiTauntSelect"
tt.sound_events.insert = "HeroSamuraiTauntIntro"
tt.sound_events.respawn = "HeroSamuraiTauntIntro"
tt.unit.hit_offset = v(0, 21)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 15)
tt.unit.pop_offset = v(0, 10)
tt.melee.attacks[1].cooldown = 1.25
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].xp_gain_factor = 2.5
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "deathStrike"
tt.melee.attacks[2].chance = 0.1
tt.melee.attacks[2].cooldown = 10 + fts(48)
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].damage_min = 180
tt.melee.attacks[2].damage_max = 180
tt.melee.attacks[2].damage_type = bor(DAMAGE_NO_DODGE, DAMAGE_INSTAKILL)
tt.melee.attacks[2].hit_time = fts(28)
tt.melee.attacks[2].pop = {
	"pop_splat"
}
tt.melee.attacks[2].pop_chance = 1
tt.melee.attacks[2].sound = "HeroSamuraiDeathStrike"
tt.melee.attacks[2].shared_cooldown = true
tt.melee.attacks[2].xp_from_skill = "death_strike"
tt.melee.attacks[2].vis_flags = bor(F_INSTAKILL)
tt.melee.attacks[2].vis_bans = bor(F_BOSS)
tt.melee.attacks[3] = table.deepclone(tt.melee.attacks[2])
tt.melee.attacks[3].chance = 1
tt.melee.attacks[3].damage_type = bor(DAMAGE_NO_DODGE, DAMAGE_TRUE)
tt.melee.attacks[3].pop = {
	"pop_sok",
	"pop_pow"
}
tt.melee.attacks[3].pop_chance = 0.1
tt.melee.attacks[3].vis_flags = F_RANGED
tt.melee.attacks[3].vis_bans = 0
tt.timed_attacks.list[1] = E:clone_c("area_attack")
tt.timed_attacks.list[1].animation = "torment"
tt.timed_attacks.list[1].cooldown = 14 + fts(68)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].damage_min = 50
tt.timed_attacks.list[1].damage_max = 80
tt.timed_attacks.list[1].damage_type = bor(DAMAGE_NO_DODGE, DAMAGE_TRUE)
tt.timed_attacks.list[1].min_count = 2
tt.timed_attacks.list[1].max_range = 100
tt.timed_attacks.list[1].damage_radius = 100
tt.timed_attacks.list[1].hit_time = fts(16)
tt.timed_attacks.list[1].damage_delay = 0.15
tt.timed_attacks.list[1].sound_hit = "HeroSamuraiTorment"
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1].torment_swords = {
	{
		0.01,
		20,
		8
	},
	{
		0.2,
		37.5,
		8
	},
	{
		0.3,
		55,
		8
	}
}
tt = RT("hero_hacksaw", "hero")

AC(tt, "melee", "ranged")

anchor_y = 0.13636363636363635
anchor_x = 0.5
image_y = 110
image_x = 90
tt.hero.fixed_stat_attack = 7
tt.hero.fixed_stat_health = 8
tt.hero.fixed_stat_range = 0
tt.hero.fixed_stat_speed = 3
tt.hero.level_stats.armor = {
	0.5,
	0.5,
	0.5,
	0.6,
	0.6,
	0.6,
	0.7,
	0.7,
	0.7,
	0.8
}
tt.hero.level_stats.hp_max = {
	420,
	440,
	460,
	480,
	500,
	520,
	540,
	560,
	580,
	600
}
tt.hero.level_stats.melee_damage_max = {
	27,
	30,
	33,
	36,
	39,
	42,
	45,
	48,
	51,
	54
}
tt.hero.level_stats.melee_damage_min = {
	9,
	10,
	11,
	12,
	13,
	14,
	15,
	16,
	17,
	18
}
tt.hero.level_stats.regen_health = {
	105,
	110,
	115,
	120,
	125,
	130,
	135,
	140,
	145,
	150
}
tt.hero.skills.timber = CC("hero_skill")
tt.hero.skills.timber.cooldown = {
	35 + fts(35),
	30 + fts(35),
	25 + fts(35)
}
tt.hero.skills.timber.xp_level_steps = {
	[10.0] = 3,
	[4.0] = 1,
	[7.0] = 2
}
tt.hero.skills.timber.xp_gain = {
	50,
	100,
	150
}
tt.hero.skills.sawblade = CC("hero_skill")
tt.hero.skills.sawblade.bounces = {
	2,
	4,
	6
}
tt.hero.skills.sawblade.xp_level_steps = {
	nil,
	1,
	nil,
	nil,
	2,
	nil,
	nil,
	3
}
tt.hero.skills.sawblade.xp_gain = {
	50,
	100,
	150
}
tt.health.dead_lifetime = 15
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = v(0, 58)
tt.hero.fn_level_up = scripts.hero_hacksaw.level_up
tt.hero.tombstone_show_time = fts(150)
tt.info.fn = scripts.hero_basic.get_info_melee
tt.info.hero_portrait = IS_PHONE and "hero_portraits_0010" or "heroPortrait_portraits_0010"
tt.info.i18n_key = "HERO_ROBOT"
tt.info.portrait = IS_PHONE and "portraits_hero_0012" or "info_portraits_hero_0012"
tt.main_script.update = scripts.hero_hacksaw.update
tt.motion.max_speed = 1.8 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(0.5, 0.13636363636363635)
tt.render.sprites[1].prefix = "hero_hacksaw"
tt.soldier.melee_slot_offset = v(13, 0)
tt.sound_events.change_rally_point = "HeroRobotTaunt"
tt.sound_events.death = "BombExplosionSound"
tt.sound_events.death2 = "HeroRobotDeath"
tt.sound_events.hero_room_select = "HeroRobotTauntSelect"
tt.sound_events.insert = "HeroRobotTauntIntro"
tt.sound_events.respawn = "HeroRobotTauntIntro"
tt.unit.hit_offset = v(0, 38)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 25)
tt.unit.pop_offset = v(0, 15)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.melee.order = {
	2,
	1
}
tt.melee.range = 65
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 2.5
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "timber"
tt.melee.attacks[2].cooldown = nil
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].hit_time = fts(14)
tt.melee.attacks[2].pop = {
	"pop_splat"
}
tt.melee.attacks[2].pop_chance = 1
tt.melee.attacks[2].sound = "HeroRobotDrill"
tt.melee.attacks[2].sound_args = {
	delay = fts(7)
}
tt.melee.attacks[2].damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_NO_DODGE)
tt.melee.attacks[2].xp_from_skill = "timber"
tt.melee.attacks[2].vis_flags = bor(F_INSTAKILL)
tt.melee.attacks[2].vis_bans = bor(F_BOSS)
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].animation = "sawblade"
tt.ranged.attacks[1].bullet = "hacksaw_sawblade"
tt.ranged.attacks[1].bullet_start_offset = {
	v(25, 21)
}
tt.ranged.attacks[1].disabled = true
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].shoot_time = fts(16)
tt.ranged.attacks[1].sound_shoot = "HeroRobotShoot"
tt.ranged.attacks[1].cooldown = 8 + fts(32)
tt.ranged.attacks[1].xp_from_skill = "sawblade"
tt = RT("hero_thor", "hero")

AC(tt, "melee", "ranged")

anchor_y = 0.25
anchor_x = 0.5
image_y = 96
image_x = 120
tt.hero.fixed_stat_attack = 8
tt.hero.fixed_stat_health = 7
tt.hero.fixed_stat_range = 0
tt.hero.fixed_stat_speed = 5
tt.hero.level_stats.armor = {
	0.4,
	0.4,
	0.4,
	0.5,
	0.5,
	0.5,
	0.6,
	0.6,
	0.6,
	0.7
}
tt.hero.level_stats.hp_max = {
	380,
	410,
	440,
	470,
	500,
	530,
	560,
	590,
	620,
	650
}
tt.hero.level_stats.melee_damage_max = {
	31,
	34,
	36,
	39,
	42,
	44,
	47,
	49,
	52,
	55
}
tt.hero.level_stats.melee_damage_min = {
	25,
	27,
	29,
	32,
	34,
	36,
	38,
	40,
	42,
	44
}
tt.hero.level_stats.regen_health = {
	95,
	103,
	110,
	118,
	125,
	133,
	140,
	148,
	155,
	163
}
tt.hero.skills.chainlightning = CC("hero_skill")
tt.hero.skills.chainlightning.count = {
	2,
	3,
	4
}
tt.hero.skills.chainlightning.damage_max = {
	40,
	60,
	80
}
tt.hero.skills.chainlightning.xp_level_steps = {
	nil,
	1,
	nil,
	nil,
	2,
	nil,
	nil,
	3
}
tt.hero.skills.chainlightning.xp_gain = {
	50,
	100,
	150
}
tt.hero.skills.thunderclap = CC("hero_skill")
tt.hero.skills.thunderclap.damage_max = {
	60,
	80,
	120
}
tt.hero.skills.thunderclap.secondary_damage_max = {
	50,
	70,
	90
}
tt.hero.skills.thunderclap.max_range = {
	70,
	75,
	80
}
tt.hero.skills.thunderclap.stun_duration = {
	3,
	4,
	6
}
tt.hero.skills.thunderclap.xp_level_steps = {
	[10.0] = 3,
	[4.0] = 1,
	[7.0] = 2
}
tt.hero.skills.thunderclap.xp_gain = {
	50,
	100,
	150
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 53)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = scripts.hero_thor.level_up
tt.hero.tombstone_show_time = fts(150)
tt.info.fn = scripts.hero_basic.get_info_melee
tt.info.i18n_key = "HERO_THOR"
tt.info.hero_portrait = IS_PHONE and "hero_portraits_0012" or "heroPortrait_portraits_0012"
tt.info.portrait = IS_PHONE and "portraits_hero_0014" or "info_portraits_hero_0014"
tt.main_script.update = scripts.hero_thor.update
tt.motion.max_speed = 2.7 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(0.5, 0.25)
tt.render.sprites[1].prefix = "hero_thor"
tt.soldier.melee_slot_offset = v(13, 0)
tt.sound_events.change_rally_point = "HeroThorTaunt"
tt.sound_events.death = "HeroThorDeath"
tt.sound_events.hero_room_select = "HeroThorTauntSelect"
tt.sound_events.insert = "HeroThorTauntIntro"
tt.sound_events.respawn = "HeroThorTauntIntro"
tt.unit.hit_offset = v(0, 22)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 20)
tt.melee.range = 65
tt.melee.cooldown = 1.5
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].hit_time = fts(13)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 2.1
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "chain"
tt.melee.attacks[2].chance = 0.25
tt.melee.attacks[2].cooldown = 1.5 + fts(34)
tt.melee.attacks[2].damage_type = DAMAGE_NO_DODGE
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].hit_time = fts(16)
tt.melee.attacks[2].shared_cooldown = true
tt.melee.attacks[2].sound = "HeroThorElectricAttack"
tt.melee.attacks[2].mod = "mod_hero_thor_chainlightning"
tt.melee.attacks[2].xp_from_skill = "chainlightning"
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].animation = "thunderclap"
tt.ranged.attacks[1].bullet = "hammer_hero_thor"
tt.ranged.attacks[1].bullet_start_offset = {
	v(25, 10)
}
tt.ranged.attacks[1].disabled = true
tt.ranged.attacks[1].cooldown = 14 + fts(28)
tt.ranged.attacks[1].max_range = 250
tt.ranged.attacks[1].min_range = 40
tt.ranged.attacks[1].shoot_time = fts(12)
tt.ranged.attacks[1].sound_shoot = "HeroThorHammer"
tt.ranged.attacks[1].xp_from_skill = "thunderclap"

tt = RT("enemy_sheep_ground", "enemy")
anchor_y = 0.2
image_y = 38
tt.enemy.gold = 0
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 80
tt.health_bar.offset = v(0, ady(32))
tt.info.i18n_key = "ENEMY_SHEEP"
tt.info.portrait = IS_PHONE and "portraits_sc_0013" or "info_portraits_sc_0013"
tt.info.enc_icon = nil
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_sheep.update
tt.motion.max_speed = 1.5 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_sheep_ground"
tt.sound_events.insert = "Sheep"
tt.sound_events.death = "DeathEplosion"
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 10)
tt.unit.mod_offset = v(0, ady(15))
tt.vis.bans = bor(F_BLOCK, F_SKELETON, F_EAT, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY)
tt.clicks_to_destroy = 8

tt = RT("enemy_sheep_fly", "enemy_sheep_ground")
anchor_y = 0.038461538461538464
image_y = 78
tt.enemy.gold = 80
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 389
tt.health_bar.offset = v(0, ady(68))
tt.motion.max_speed = 2.08 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_sheep_fly"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.ui.click_rect.pos.y = 40
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, ady(56))
tt.unit.mod_offset = v(0, ady(48))
tt.unit.show_blood_pool = false
tt.vis.flags = bor(F_ENEMY, F_FLYING)

--哥布林
tt = RT("enemy_goblin", "enemy")
AC(tt, "melee")
image_y = 32
image_x = 46
anchor_y = 0.2
anchor_x = 0.5
tt.enemy.gold = 3
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 90
tt.health_bar.offset = v(0, 25)
tt.info.i18n_key = "ENEMY_GOBLIN"
tt.info.enc_icon = 1
tt.info.portrait = IS_PHONE and "portraits_sc_0006" or "info_portraits_sc_0006"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 4
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 1.2 * FPS
tt.render.sprites[1].anchor = v(0.5, anchor_y)
tt.render.sprites[1].prefix = "goblin"
tt.sound_events.death = "DeathGoblin"
tt.unit.hit_offset = v(0, 8)
tt.unit.mod_offset = v(adx(22), ady(15))

--兽人
tt = RT("enemy_fat_orc", "enemy")
AC(tt, "melee")
anchor_y = 0.19
anchor_x = 0.5
image_y = 42
image_x = 58
tt.enemy.gold = 9
tt.enemy.melee_slot = v(18, 0)
tt.health.armor = 0.3
tt.health.hp_max = 480
tt.health_bar.offset = v(0, 30)
tt.info.i18n_key = "ENEMY_FAT_ORC"
tt.info.enc_icon = 2
tt.info.portrait = IS_PHONE and "portraits_sc_0007" or "info_portraits_sc_0007"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 8
tt.melee.attacks[1].damage_min = 4
tt.melee.attacks[1].hit_time = fts(6)
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.19)
tt.render.sprites[1].prefix = "enemy_fat_orc"
tt.sound_events.death = "DeathOrc"
tt.unit.hit_offset = v(0, 14)
tt.unit.mod_offset = v(adx(30), ady(20))

--土狼
tt = RT("enemy_wolf_small", "enemy")
AC(tt, "dodge", "melee")
anchor_y = 0.21
anchor_x = 0.5
image_y = 28
image_x = 38
tt.dodge.chance = 0.3
tt.dodge.silent = true
tt.enemy.gold = 5
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 35
tt.health_bar.offset = v(0, 25)
tt.info.i18n_key = "ENEMY_WULF"
tt.info.enc_icon = 13
tt.info.portrait = IS_PHONE and "portraits_sc_0012" or "info_portraits_sc_0012"
tt.melee.attacks[1].cooldown = 1 + fts(14)
tt.melee.attacks[1].damage_max = 3
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "WolfAttack"
tt.motion.max_speed = 2.5 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.21)
tt.render.sprites[1].prefix = "enemy_wolf_small"
tt.sound_events.death = "DeathPuff"
tt.sound_events.death_by_explosion = "DeathPuff"
tt.unit.can_explode = false
tt.unit.show_blood_pool = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 11)
tt.unit.mod_offset = v(adx(22), ady(14))
tt.vis.bans = bor(F_SKELETON)

--座狼
tt = RT("enemy_wolf", "enemy")
AC(tt, "dodge", "melee")
anchor_y = 0.26
anchor_x = 0.5
image_y = 50
image_x = 60
tt.dodge.chance = 0.5
tt.dodge.silent = true
tt.enemy.gold = 12
tt.enemy.melee_slot = v(25, 0)
tt.health.hp_max = 320
tt.health.magic_armor = 0.5
tt.health_bar.offset = v(0, 35)
tt.info.i18n_key = "ENEMY_WORG"
tt.info.enc_icon = 14
tt.info.portrait = IS_PHONE and "portraits_sc_0020" or "info_portraits_sc_0020"
tt.melee.attacks[1].cooldown = 1 + fts(14)
tt.melee.attacks[1].damage_max = 18
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "WolfAttack"
tt.motion.max_speed = 2 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.26)
tt.render.sprites[1].prefix = "enemy_wolf"
tt.sound_events.death = "DeathPuff"
tt.sound_events.death_by_explosion = "DeathPuff"
tt.unit.can_explode = false
tt.unit.show_blood_pool = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 13)
tt.unit.marker_offset.y = 2
tt.unit.mod_offset = v(adx(29), ady(26))
tt.vis.bans = bor(F_SKELETON)

--暗影弓箭手
tt = RT("enemy_shadow_archer", "enemy")
AC(tt, "melee", "ranged")
anchor_y = 0.2
anchor_x = 0.5
image_y = 36
image_x = 54
tt.enemy.gold = 16
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 180
tt.health.magic_armor = 0.3
tt.health_bar.offset = v(0, 31)
tt.info.i18n_key = "ENEMY_SHADOW_ARCHER"
tt.info.enc_icon = 11
tt.info.portrait = IS_PHONE and "portraits_sc_0025" or "info_portraits_sc_0025"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(4)
tt.motion.max_speed = 1.2 * FPS
tt.ranged.attacks[1].bullet = "arrow_shadow_archer"
tt.ranged.attacks[1].bullet_start_offset = {
	v(4, 12.5)
}
tt.ranged.attacks[1].cooldown = 1 + fts(12)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 145
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].shoot_time = fts(7)
tt.render.sprites[1].anchor = v(0.5, 0.2)
tt.render.sprites[1].prefix = "enemy_shadow_archer"
tt.sound_events.death = "DeathHuman"
tt.unit.hit_offset = v(0, 15)
tt.unit.mod_offset = v(adx(26), ady(20))
tt.unit.marker_offset.y = 1

--萨满
tt = RT("enemy_shaman", "enemy")
AC(tt, "melee", "timed_attacks")
anchor_y = 0.2
anchor_x = 0.5
image_y = 60
image_x = 60
tt.enemy.gold = 10
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 500
tt.health.magic_armor = 0.85
tt.health_bar.offset = v(0, 33)
tt.info.i18n_key = "ENEMY_SHAMAN"
tt.info.enc_icon = 3
tt.info.portrait = IS_PHONE and "portraits_sc_0009" or "info_portraits_sc_0009"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_shaman.update
tt.melee.attacks[1].cooldown = 1 + fts(18)
tt.melee.attacks[1].damage_max = 5
tt.melee.attacks[1].damage_min = 3
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.2)
tt.render.sprites[1].prefix = "enemy_shaman"
tt.sound_events.death = "DeathGoblin"
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].animation = "heal"
tt.timed_attacks.list[1].cast_time = fts(14)
tt.timed_attacks.list[1].cooldown = 8
tt.timed_attacks.list[1].max_count = 3
tt.timed_attacks.list[1].max_range = 95
tt.timed_attacks.list[1].mod = "mod_shaman_heal"
tt.timed_attacks.list[1].sound = "EnemyHealing"
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)
tt.unit.hit_offset = v(0, 14)
tt.unit.marker_offset = v(0, -2)
tt.unit.mod_offset = v(adx(30), ady(20))

--石像鬼
tt = RT("enemy_gargoyle", "enemy")
anchor_y = 0
anchor_x = 0.5
image_y = 88
image_x = 58
tt.enemy.gold = 12
tt.health.hp_max = 490
tt.health_bar.offset = v(adx(29), ady(69))
tt.info.i18n_key = "ENEMY_GARGOYLE"
tt.info.enc_icon = 10
tt.info.portrait = IS_PHONE and "portraits_sc_0010" or "info_portraits_sc_0010"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_passive.update
tt.motion.max_speed = 1.2 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_gargoyle"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.sound_events.death = "DeathPuff"
tt.ui.click_rect = r(-14, 34, 28, 30)
tt.unit.can_explode = false
tt.unit.can_disintegrate = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, 52)
tt.unit.hide_after_death = true
tt.unit.mod_offset = v(adx(31), ady(50))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_THORN, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)

--食人魔
tt = RT("enemy_ogre", "enemy")
AC(tt, "melee")
anchor_y = 0.2
anchor_x = 0.5
image_y = 80
image_x = 86
tt.enemy.gold = 50
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = v(24, 0)
tt.health.hp_max = 3800
tt.health_bar.offset = v(0, 53)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_OGRE"
tt.info.enc_icon = 4
tt.info.portrait = IS_PHONE and "portraits_sc_0011" or "info_portraits_sc_0011"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 60
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].hit_time = fts(16)
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_ogre"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = v(34, 45)
tt.ui.click_rect.pos.x = -17
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 20)
tt.unit.mod_offset = v(adx(42), ady(33))
tt.unit.size = UNIT_SIZE_MEDIUM


tt = RT("enemy_spider_tiny", "enemy")
AC(tt, "melee")
anchor_y = 0.25
anchor_x = 0.5
image_y = 24
image_x = 30
tt.enemy.gold = 1
tt.enemy.melee_slot = v(20, 0)
tt.health.hp_max = 10
tt.health.magic_armor = 0.5
tt.health_bar.offset = v(0, 16)
tt.info.i18n_key = "ENEMY_SPIDERTINY"
tt.info.portrait = IS_PHONE and "portraits_sc_0023" or "info_portraits_sc_0023"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 5
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "SpiderAttack"
tt.motion.max_speed = 2 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_spider_tiny"
tt.sound_events.death = "DeathEplosionShortA"
tt.unit.blood_color = BLOOD_GREEN
tt.unit.explode_fx = "fx_spider_explode"
tt.unit.hit_offset = v(0, 8)
tt.unit.marker_offset = v(0, ady(5))
tt.unit.mod_offset = v(adx(18), ady(13))
tt.vis.bans = bor(F_SKELETON, F_POISON)


tt = RT("enemy_spider_small", "enemy")
AC(tt, "melee")
anchor_y = 0.25
anchor_x = 0.5
image_y = 28
image_x = 36
tt.enemy.gold = 6
tt.enemy.melee_slot = v(20, 0)
tt.health.hp_max = 160
tt.health.magic_armor = 0.65
tt.health_bar.offset = v(0, 22)
tt.info.i18n_key = "ENEMY_SPIDERSMALL"
tt.info.enc_icon = 8
tt.info.portrait = IS_PHONE and "portraits_sc_0022" or "info_portraits_sc_0022"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 18
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "SpiderAttack"
tt.motion.max_speed = 1.5 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_spider_small"
tt.sound_events.death = "DeathEplosion"
tt.unit.blood_color = BLOOD_GREEN
tt.unit.explode_fx = "fx_spider_explode"
tt.unit.hit_offset = v(0, 8)
tt.unit.marker_offset = v(0, -1)
tt.unit.mod_offset = v(adx(20), ady(15))
tt.vis.bans = bor(F_SKELETON, F_POISON)

--蜘蛛主母
tt = RT("enemy_spider_big", "enemy")
AC(tt, "melee", "timed_attacks")
anchor_y = 0.25
anchor_x = 0.5
image_y = 40
image_x = 56
tt.enemy.gold = 20
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(24, 0)
tt.health.hp_max = 3250
tt.health.magic_armor = 0.3
tt.health_bar.offset = v(0, 32)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_SPIDER"
tt.info.enc_icon = 9
tt.info.portrait = IS_PHONE and "portraits_sc_0021" or "info_portraits_sc_0021"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_spider_big.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 25
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "SpiderAttack"
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_spider"
tt.sound_events.death = "DeathEplosion"
tt.timed_attacks.list[1] = E:clone_c("bullet_attack")
tt.timed_attacks.list[1].bullet = "enemy_spider_egg"
tt.timed_attacks.list[1].max_cooldown = 10
tt.timed_attacks.list[1].max_count = 3
tt.timed_attacks.list[1].min_cooldown = 5
tt.ui.click_rect = r(-20, -5, 40, 30)
tt.unit.blood_color = BLOOD_GREEN
tt.unit.explode_fx = "fx_spider_explode"
tt.unit.hit_offset = v(0, 8)
tt.unit.marker_offset = v(-0.4, -2.2)
tt.unit.mod_offset = v(adx(26), ady(18))
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_SKELETON, F_POISON)

--土匪
tt = RT("enemy_brigand", "enemy")
AC(tt, "melee")
anchor_y = 0.2
anchor_x = 0.5
image_y = 38
image_x = 50
tt.enemy.gold = 15
tt.enemy.melee_slot = v(18, 0)
tt.health.armor = 0.7
tt.health.hp_max = 960
tt.health_bar.offset = v(0, 31)
tt.info.i18n_key = "ENEMY_BRIGAND"
tt.info.enc_icon = 6
tt.info.portrait = IS_PHONE and "portraits_sc_0018" or "info_portraits_sc_0018"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 10
tt.melee.attacks[1].damage_min = 6
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_brigand"
tt.sound_events.death = "DeathHuman"
tt.unit.hit_offset = v(0, 14)
tt.unit.mod_offset = v(adx(24), ady(19))

---黑暗骑士
tt = RT("enemy_dark_knight", "enemy")
AC(tt, "melee")
anchor_y = 0.2
anchor_x = 0.5
image_y = 46
image_x = 64
tt.enemy.gold = 25
tt.enemy.melee_slot = v(24, 0)
tt.health.armor = 0.8
tt.health.hp_max = 1350
tt.health_bar.offset = v(0, 35)
tt.info.i18n_key = "ENEMY_DARK_KNIGHT"
tt.info.enc_icon = 12
tt.info.portrait = IS_PHONE and "portraits_sc_0024" or "info_portraits_sc_0024"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 25
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].hit_time = fts(7)
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_dark_knight"
tt.sound_events.death = "DeathHuman"
tt.unit.hit_offset = v(0, 16)
tt.unit.mod_offset = v(adx(32), ady(20))
tt.unit.marker_offset.y = -2

--掠夺者
tt = RT("enemy_marauder", "enemy")
AC(tt, "melee")
anchor_y = 0.22
anchor_x = 0.5
image_y = 56
image_x = 78
tt.enemy.gold = 40
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = v(24, 0)
tt.health.armor = 0.6
tt.health.hp_max = 2600
tt.health_bar.offset = v(0, 48)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_MARAUDER"
tt.info.enc_icon = 7
tt.info.portrait = IS_PHONE and "portraits_sc_0019" or "info_portraits_sc_0019"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 24
tt.melee.attacks[1].damage_min = 16
tt.melee.attacks[1].hit_time = fts(10)
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_marauder"
tt.sound_events.death = "DeathHuman"
tt.ui.click_rect = r(-20, -5, 40, 40)
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 20)
tt.unit.mod_offset = v(adx(39), ady(24))
tt.unit.size = UNIT_SIZE_MEDIUM

--强盗
tt = RT("enemy_bandit", "enemy")
AC(tt, "melee", "dodge")
anchor_y = 0.2
anchor_x = 0.5
image_y = 34
image_x = 48
tt.dodge.chance = 0.5
tt.dodge.silent = true
tt.enemy.gold = 8
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 170
tt.health_bar.offset = v(0, 30)
tt.info.i18n_key = "ENEMY_BANDIT"
tt.info.enc_icon = 5
tt.info.portrait = IS_PHONE and "portraits_sc_0008" or "info_portraits_sc_0008"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(4)
tt.motion.max_speed = 1.2 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_bandit"
tt.sound_events.death = "DeathHuman"
tt.unit.hit_offset = v(0, 14)
tt.unit.marker_offset = v(0, 2)
tt.unit.mod_offset = v(adx(24), ady(17))

--黑暗屠夫
tt = RT("enemy_slayer", "enemy")
AC(tt, "melee")
anchor_y = 0.22
anchor_x = 0.5
image_y = 66
image_x = 74
tt.enemy.gold = 100
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = v(24, 0)
tt.health.armor = 0.90
tt.health.hp_max = 6200
tt.health_bar.offset = v(0, 50)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_SLAYER"
tt.info.enc_icon = 22
tt.info.portrait = IS_PHONE and "portraits_sc_0046" or "info_portraits_sc_0046"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 76
tt.melee.attacks[1].damage_min = 24
tt.melee.attacks[1].hit_time = fts(7)
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_slayer"
tt.sound_events.death = "DeathHuman"
tt.ui.click_rect.size = v(32, 42)
tt.ui.click_rect.pos.x = -16
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 20)
tt.unit.mod_offset = v(adx(37), ady(25))
tt.unit.size = UNIT_SIZE_MEDIUM

--火箭骑兵
tt = RT("enemy_rocketeer", "enemy")
anchor_y = 0
anchor_x = 0.5
image_y = 88
image_x = 80
tt.enemy.gold = 30
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 340
tt.health.on_damage = scripts.enemy_rocketeer.on_damage
tt.health_bar.offset = v(0, 78)
tt.info.i18n_key = "ENEMY_ROCKETEER"
tt.info.enc_icon = 21
tt.info.portrait = IS_PHONE and "portraits_sc_0045" or "info_portraits_sc_0045"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_passive.update
tt.motion.max_speed = 1.2 * FPS
tt.render.sprites[1].anchor = v(0.5, 0)
tt.render.sprites[1].prefix = "enemy_rocketeer"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.sound_events.death = "BombExplosionSound"
tt.ui.click_rect = r(-14, 40, 28, 34)
tt.unit.can_explode = false
tt.unit.can_disintegrate = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 58)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(adx(40), ady(56))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_THORN, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)

--巨魔
tt = RT("enemy_troll", "enemy")
AC(tt, "melee", "auras")
anchor_y = 0.22727272727272727
anchor_x = 0.5
image_y = 44
image_x = 60
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_troll_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 25
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 1280
tt.health.armor = 0.2
tt.info.i18n_key = "ENEMY_TROLL"
tt.info.enc_icon = 17
tt.info.portrait = IS_PHONE and "portraits_sc_0029" or "info_portraits_sc_0029"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(7)
tt.motion.max_speed = 0.9 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_troll"
tt.sound_events.death = "DeathTroll"
tt.unit.hit_offset = v(0, 13)
tt.unit.mod_offset = v(adx(28), ady(23))

--白狼
tt = RT("enemy_whitewolf", "enemy")
AC(tt, "melee", "dodge")
anchor_y = 0.3275862068965517
anchor_x = 0.5
image_y = 58
image_x = 64
tt.dodge.chance = 0.5
tt.dodge.silent = true
tt.enemy.gold = 35
tt.enemy.melee_slot = v(24, 0)
tt.health.hp_max = 850
tt.health.magic_armor = 0.5
tt.health_bar.offset = v(0, 39)
tt.info.i18n_key = "ENEMY_WHITE_WOLF"
tt.info.enc_icon = 16
tt.info.portrait = IS_PHONE and "portraits_sc_0032" or "info_portraits_sc_0032"
tt.melee.attacks[1].cooldown = 1 + fts(14)
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "WolfAttack"
tt.motion.max_speed = 2 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_whitewolf"
tt.sound_events.death = "DeathPuff"
tt.sound_events.death_by_explosion = "DeathPuff"
tt.ui.click_rect.size.x = 32
tt.ui.click_rect.pos.x = -16
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 13)
tt.unit.mod_offset = v(adx(32), ady(32))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_SKELETON)

--雪人
tt = RT("enemy_yeti", "enemy")
AC(tt, "melee")
anchor_y = 0.19
anchor_x = 0.5
image_y = 80
image_x = 100
tt.enemy.gold = 120
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = v(25, 0)
tt.health.hp_max = 7100
tt.health_bar.offset = v(0, 56)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_YETI"
tt.info.enc_icon = 20
tt.info.portrait = IS_PHONE and "portraits_sc_0033" or "info_portraits_sc_0033"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2.5
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 150
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].damage_radius = 50
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = v(30, 0)
tt.melee.attacks[1].hit_time = fts(13)
tt.melee.attacks[1].sound = "AreaAttack"
tt.melee.attacks[1].sound_args = {
	delay = fts(13)
}
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_yeti"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = v(50, 50)
tt.ui.click_rect.pos.x = -25
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 24)
tt.unit.mod_offset = v(adx(47), ady(35))
tt.unit.size = UNIT_SIZE_LARGE

--森林巨魔
tt = RT("enemy_forest_troll", "enemy")
AC(tt, "melee", "auras")
anchor_y = 0.21
anchor_x = 0.5
image_y = 100
image_x = 156
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_forest_troll_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 200
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = v(35, 0)
tt.health.hp_max = 8200
tt.health.armor = 0.3
tt.health_bar.offset = v(0, 76)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_FOREST_TROLL"
tt.info.enc_icon = 39
tt.info.portrait = IS_PHONE and "portraits_sc_0062" or "info_portraits_sc_0060"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2.5
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 150
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].damage_radius = 50
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = v(30, 0)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound = "AreaAttack"
tt.melee.attacks[1].sound_args = {
	delay = fts(15)
}
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_forest_troll"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = v(58, 55)
tt.ui.click_rect.pos = v(-30, 3)
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 30)
tt.unit.marker_offset = v(1, 2)
tt.unit.mod_offset = v(adx(78), ady(45))
tt.unit.size = UNIT_SIZE_LARGE

--兽人勇士
tt = RT("enemy_orc_armored", "enemy")
AC(tt, "melee")
anchor_y = 0.14
anchor_x = 0.5
image_y = 48
image_x = 70
tt.enemy.gold = 30
tt.enemy.melee_slot = v(18, 0)
tt.health.armor = 0.8
tt.health.hp_max = 2800
tt.health_bar.offset = v(0, 36)
tt.info.i18n_key = "ENEMY_ORC_ARMORED"
tt.info.enc_icon = IS_PHONE and 37 or 36
tt.info.portrait = IS_PHONE and "portraits_sc_0060" or "info_portraits_sc_0059"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(6)
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_orc_armored"
tt.sound_events.death = "DeathOrc"
tt.ui.click_rect.size.y = 28
tt.ui.click_rect.pos.y = 3
tt.unit.hit_offset = v(0, 14)
tt.unit.marker_offset.y = 2
tt.unit.mod_offset = v(adx(34), ady(21))

--座狼骑士
tt = RT("enemy_orc_rider", "enemy")
AC(tt, "melee", "death_spawns")
anchor_y = 0.14
anchor_x = 0.5
image_y = 62
image_x = 62
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "enemy_orc_armored"
tt.enemy.gold = 25
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(30, 0)
tt.health.hp_max = 2250
tt.health.magic_armor = 0.7
tt.health_bar.offset = v(0, 48)
tt.info.i18n_key = "ENEMY_ORC_RIDER"
tt.info.enc_icon = IS_PHONE and 38 or 37
tt.info.portrait = IS_PHONE and "portraits_sc_0060" or "info_portraits_sc_0059"
tt.melee.attacks[1].cooldown = 1 + fts(14)
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "WolfAttack"
tt.motion.max_speed = 1.4 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_orc_rider"
tt.sound_events.death = "DeathPuff"
tt.ui.click_rect.size = v(32, 38)
tt.ui.click_rect.pos = v(-16, 2)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 23)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(adx(31), ady(29))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_SKELETON)

--巨魔冠军
tt = RT("enemy_troll_axe_thrower", "enemy")
AC(tt, "melee", "ranged", "auras")
anchor_y = 0.2
anchor_x = 0.5
image_y = 50
image_x = 60
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].cooldown = 0
tt.auras.list[1].name = "aura_troll_axe_thrower_regen"
tt.enemy.gold = 50
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 2200
tt.health_bar.offset = v(0, 43)
tt.info.i18n_key = "ENEMY_TROLL_AXE_THROWER"
tt.info.enc_icon = 18
tt.info.portrait = IS_PHONE and "portraits_sc_0030" or "info_portraits_sc_0030"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 50
tt.melee.attacks[1].damage_min = 30
tt.melee.attacks[1].hit_time = fts(8)
tt.motion.max_speed = 0.8 * FPS
tt.ranged.attacks[1].bullet = "axe_troll_axe_thrower"
tt.ranged.attacks[1].bullet_start_offset = {
	v(4, 15)
}
tt.ranged.attacks[1].cooldown = 1 + fts(15)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 145
tt.ranged.attacks[1].min_range = 55
tt.ranged.attacks[1].shoot_time = fts(7)
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_troll_axe_thrower"
tt.sound_events.death = "DeathTroll"
tt.ui.click_rect.size = v(30, 40)
tt.ui.click_rect.pos.x = -15
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 18)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(adx(29), ady(21))
tt.unit.size = UNIT_SIZE_MEDIUM

--侵袭者
tt = RT("enemy_raider", "enemy")
AC(tt, "melee", "ranged")
anchor_y = 0.23
anchor_x = 0.5
image_y = 68
image_x = 88
tt.enemy.gold = 50
tt.enemy.melee_slot = v(23, 0)
tt.health.armor = 0.95
tt.health.hp_max = 5000
tt.health_bar.offset = v(0, 49)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_RAIDER"
tt.info.enc_icon = 46
tt.info.portrait = IS_PHONE and "portraits_sc_0070" or "info_portraits_sc_0070"
tt.melee.attacks[1].cooldown = 3
tt.melee.attacks[1].damage_max = 80
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].hit_time = fts(6)
tt.ranged.attacks[1].bullet = "ball_raider"
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 24)
}
tt.ranged.attacks[1].cooldown = 1.5 + fts(15)
tt.ranged.attacks[1].hold_advance = false
tt.ranged.attacks[1].max_range = 165
tt.ranged.attacks[1].min_range = 55
tt.ranged.attacks[1].shoot_time = fts(15)
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_raider"
tt.sound_events.death = "DeathHuman"
tt.ui.click_rect.size = v(32, 44)
tt.ui.click_rect.pos.x = -16
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 20)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(adx(43), ady(34))
tt.unit.size = UNIT_SIZE_MEDIUM

--抢夺者
tt = RT("enemy_pillager", "enemy")
AC(tt, "melee")
anchor_y = 0.23
anchor_x = 0.5
image_y = 118
image_x = 154
tt.enemy.gold = 100
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = v(33, 0)
tt.health.hp_max = 7800
tt.health.magic_armor = 0.9
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = v(0, 61)
tt.info.i18n_key = "ENEMY_PILLAGER"
tt.info.enc_icon = 47
tt.info.portrait = IS_PHONE and "portraits_sc_0071" or "info_portraits_sc_0071"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 100
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].damage_radius = 50
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_offset = v(30, 0)
tt.melee.attacks[1].hit_time = fts(14)
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_pillager"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = v(44, 58)
tt.ui.click_rect.pos.x = -22
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 30)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(adx(75), ady(47))
tt.unit.size = UNIT_SIZE_MEDIUM

--巨魔粉碎者
tt = RT("enemy_troll_brute", "enemy")
AC(tt, "melee", "auras")
anchor_y = 0.2125
anchor_x = 0.5
image_y = 80
image_x = 104
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_troll_brute_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 150
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = v(35, 0)
tt.health.armor = 0.6
tt.health.hp_max = 9800
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = v(0, 54)
tt.info.i18n_key = "ENEMY_TROLL_BRUTE"
tt.info.enc_icon = 51
tt.info.portrait = IS_PHONE and "portraits_sc_0074" or "info_portraits_sc_0074"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].count = 3
tt.melee.attacks[1].damage_max = 165
tt.melee.attacks[1].damage_min = 95
tt.melee.attacks[1].damage_radius = 44.800000000000004
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = v(30, 0)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound_hit = "AreaAttack"
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_troll_brute"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = v(30, 40)
tt.ui.click_rect.pos.x = -15
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 18)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 14)
tt.unit.size = UNIT_SIZE_MEDIUM

--巨魔首领
tt = RT("enemy_troll_chieftain", "enemy")
AC(tt, "melee", "auras", "timed_attacks")
anchor_y = 0.2
anchor_x = 0.5
image_y = 58
image_x = 78
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_troll_chieftain_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 70
tt.enemy.lives_cost = 6
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 3400
tt.health.armor = 0.3
tt.health_bar.offset = v(0, 46)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_TROLL_CHIEFTAIN"
tt.info.enc_icon = 19
tt.info.portrait = IS_PHONE and "portraits_sc_0031" or "info_portraits_sc_0031"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_troll_chieftain.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(16)
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].animation = "special"
tt.timed_attacks.list[1].cooldown = 6
tt.timed_attacks.list[1].cast_sound = "EnemyChieftain"
tt.timed_attacks.list[1].cast_time = fts(8)
tt.timed_attacks.list[1].loops = 3
tt.timed_attacks.list[1].max_count = 3
tt.timed_attacks.list[1].max_range = 180
tt.timed_attacks.list[1].mods = {
	"mod_troll_rage",
	"mod_troll_heal"
}
tt.timed_attacks.list[1].exclude_with_mods = {
	"mod_troll_rage"
}
tt.timed_attacks.list[1].allowed_templates = {
	"enemy_troll",
	"enemy_troll_axe_thrower",
	"enemy_troll_skater"
}
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_troll_chieftain"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = v(32, 40)
tt.ui.click_rect.pos.x = -16
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 20)
tt.unit.mod_offset = v(adx(37), ady(18))
tt.unit.size = UNIT_SIZE_MEDIUM

--傀儡头
tt = RT("enemy_golem_head", "enemy")
AC(tt, "melee")
anchor_y = 0.20588235294117646
anchor_x = 0.5
image_y = 34
image_x = 40
tt.enemy.gold = 10
tt.enemy.melee_slot = v(20, 0)
tt.health.hp_max = 125
tt.health_bar.offset = v(0, 23)
tt.info.i18n_key = "ENEMY_GOLEM_HEAD"
tt.info.enc_icon = 15
tt.info.portrait = IS_PHONE and "portraits_sc_0028" or "info_portraits_sc_0028"
tt.melee.attacks[1].cooldown = 1 + fts(20)
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(8)
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_golem_head"
tt.sound_events.death = "DeathPuff"
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 8)
tt.unit.mod_offset = v(adx(22), ady(15))
tt.unit.show_blood_pool = false

--哥布林投弹手
tt = RT("enemy_goblin_zapper", "enemy")
AC(tt, "melee", "ranged", "death_spawns")
anchor_y = 0.22
anchor_x = 0.5
image_y = 58
image_x = 52
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_goblin_zapper_death"
tt.death_spawns.delay = 0.11
tt.enemy.gold = 10
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 640
tt.health_bar.offset = v(0, 34)
tt.info.i18n_key = "ENEMY_GOBLIN_ZAPPER"
tt.info.enc_icon = IS_PHONE and 36 or 38
tt.info.portrait = IS_PHONE and "portraits_sc_0061" or "info_portraits_sc_0061"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(8)
tt.motion.max_speed = 1.2 * FPS
tt.ranged.attacks[1].bullet = "bomb_goblin_zapper"
tt.ranged.attacks[1].bullet_start_offset = {
	v(4, 12.5)
}
tt.ranged.attacks[1].cooldown = 1 + fts(12)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].ignore_hit_offset = true
tt.ranged.attacks[1].max_range = 165
tt.ranged.attacks[1].min_range = 60
tt.ranged.attacks[1].shoot_time = fts(7)
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_goblin_zapper"
tt.sound_events.death = "BombExplosionSound"
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 13)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(adx(26), ady(22))
tt.unit.show_blood_pool = false

--恶魔之子
tt = RT("enemy_demon", "enemy")
AC(tt, "melee", "death_spawns")
anchor_y = 0.2
anchor_x = 0.5
image_y = 38
image_x = 44
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_demon_death"
tt.death_spawns.delay = 0.11
tt.enemy.gold = 20
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 1850
tt.health.magic_armor = 0.6
tt.health_bar.offset = v(0, 29)
tt.info.i18n_key = "ENEMY_DEMON"
tt.info.enc_icon = 23
tt.info.portrait = IS_PHONE and "portraits_sc_0048" or "info_portraits_sc_0048"
tt.main_script.insert = scripts.enemy_base_portal.insert
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(7)
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon"
tt.sound_events.death = "DeathPuff"
tt.unit.blood_color = BLOOD_RED
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 14)
tt.unit.mod_offset = v(adx(22), ady(19))
tt.unit.show_blood_pool = false

--恶魔领主
tt = RT("enemy_demon_mage", "enemy")
AC(tt, "melee", "death_spawns", "timed_attacks")
anchor_y = 0.15
anchor_x = 0.5
image_y = 56
image_x = 58
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_demon_mage_death"
tt.death_spawns.delay = 0.11
tt.enemy.gold = 60
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = v(24, 0)
tt.health.hp_max = 3600
tt.health.magic_armor = 0.6
tt.health_bar.offset = v(0, 43)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_DEMON_MAGE"
tt.info.enc_icon = 24
tt.info.portrait = IS_PHONE and "portraits_sc_0049" or "info_portraits_sc_0049"
tt.main_script.insert = scripts.enemy_base_portal.insert
tt.main_script.update = scripts.enemy_demon_mage.update
tt.melee.attacks[1].cooldown = 1 + fts(20)
tt.melee.attacks[1].damage_max = 75
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon_mage"
tt.sound_events.death = "DeathPuff"
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].animation = "special"
tt.timed_attacks.list[1].cast_time = fts(15)
tt.timed_attacks.list[1].cooldown = 6
tt.timed_attacks.list[1].max_count = 4
tt.timed_attacks.list[1].max_range = 180
tt.timed_attacks.list[1].mod = "mod_demon_shield"
tt.timed_attacks.list[1].sound = "EnemyHealing"
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)
tt.timed_attacks.list[1].allowed_templates = {
	"enemy_demon",
	"enemy_demon_cerberus",
	"enemy_demon_flareon",
	"enemy_demon_gulaemon",
	"enemy_demon_legion",
	"enemy_demon_wolf",
	"enemy_rotten_lesser"
}
tt.ui.click_rect.size = v(32, 40)
tt.ui.click_rect.pos.x = -16
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 20)
tt.unit.mod_offset = v(adx(30), ady(20))
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM

--恶魔猎犬
tt = RT("enemy_demon_wolf", "enemy")
AC(tt, "melee", "death_spawns", "dodge")
anchor_y = 0.15
anchor_x = 0.5
image_y = 40
image_x = 58
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_demon_wolf_death"
tt.death_spawns.delay = 0.11
tt.dodge.chance = 0.5
tt.dodge.silent = true
tt.enemy.gold = 25
tt.enemy.melee_slot = v(24, 0)
tt.health.hp_max = 650
tt.health.magic_armor = 0.6
tt.health_bar.offset = v(0, 31)
tt.info.i18n_key = "ENEMY_DEMON_WOLF"
tt.info.enc_icon = 25
tt.info.portrait = IS_PHONE and "portraits_sc_0050" or "info_portraits_sc_0050"
tt.main_script.insert = scripts.enemy_base_portal.insert
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "WolfAttack"
tt.motion.max_speed = 1.5 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon_wolf"
tt.sound_events.death = "DeathPuff"
tt.sound_events.death_by_explosion = "DeathPuff"
tt.ui.click_rect.size.x = 32
tt.ui.click_rect.pos = v(-16, 0.5)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 13)
tt.unit.mod_offset = v(adx(30), ady(20))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_SKELETON)

--魔精
tt = RT("enemy_demon_imp", "enemy")
anchor_y = 0
anchor_x = 0.5
image_y = 96
image_x = 78
tt.enemy.gold = 25
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 350
tt.health_bar.offset = v(0, 72)
tt.info.i18n_key = "ENEMY_DEMON_IMP"
tt.info.enc_icon = 26
tt.info.portrait = IS_PHONE and "portraits_sc_0051" or "info_portraits_sc_0051"
tt.main_script.insert = scripts.enemy_base_portal.insert
tt.main_script.update = scripts.enemy_passive.update
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon_imp"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.sound_events.death = "DeathPuff"
tt.ui.click_rect = r(-14, 35, 30, 32)
tt.unit.can_explode = false
tt.unit.can_disintegrate = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 58)
tt.unit.mod_offset = v(adx(38), ady(50))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_THORN, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)

--熔岩元素
tt = RT("enemy_lava_elemental", "enemy")
AC(tt, "melee")
anchor_y = 0.19
anchor_x = 0.5
image_y = 84
image_x = 108
tt.enemy.gold = 100
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = v(25, 0)
tt.health.hp_max = 12500
tt.health.armor = 0.4
tt.health_bar.offset = v(0, 62)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = IS_PHONE and "portraits_sc_0055" or "info_portraits_sc_0055"
tt.info.i18n_key = "ENEMY_LAVA_ELEMENTAL"
tt.info.enc_icon = 30
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2.5
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 150
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].damage_radius = 50
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = v(30, 0)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound_hit = "AreaAttack"
tt.motion.max_speed = 0.5 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_lava_elemental"
tt.sound_events.death = "RockElementalDeath"
tt.ui.click_rect.size = v(50, 56)
tt.ui.click_rect.pos.x = -25
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 24)
tt.unit.mod_offset = v(adx(53), ady(38))
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_POISON)

--萨雷格兹之子
tt = RT("enemy_sarelgaz_small", "enemy")
AC(tt, "melee")
anchor_y = 0.19
anchor_x = 0.5
image_y = 68
image_x = 96
tt.enemy.gold = 80
tt.enemy.melee_slot = v(35, 0)
tt.health.armor = 0.7
tt.health.hp_max = 7250
tt.health.magic_armor = 0.7
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = v(0, 51)
tt.info.portrait = IS_PHONE and "portraits_sc_0058" or "info_portraits_sc_0058"
tt.info.i18n_key = "ENEMY_SARELGAZ_SMALL"
tt.info.enc_icon = 31
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 100
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].sound = "SpiderAttack"
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.19)
tt.render.sprites[1].prefix = "enemy_sarelgaz_small"
tt.sound_events.death = "DeathEplosion"
tt.ui.click_rect.size = v(54, 50)
tt.ui.click_rect.pos.x = -27
tt.unit.blood_color = BLOOD_GREEN
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 23)
tt.unit.mod_offset = v(adx(45), ady(35))
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_POISON, F_SKELETON)


tt = RT("enemy_rotten_lesser", "enemy")
AC(tt, "melee", "death_spawns")
anchor_y = 0.21621621621621623
anchor_x = 0.5
image_y = 74
image_x = 90
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_rotten_lesser_death"
tt.enemy.gold = 20
tt.enemy.melee_slot = v(26, 0)
tt.health.hp_max = 500
tt.info.i18n_key = "ENEMY_ROTTEN_LESSER"
tt.info.enc_icon = 58
tt.info.portrait = IS_PHONE and "portraits_sc_0081" or "info_portraits_sc_0081"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 18
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.21621621621621623)
tt.render.sprites[1].prefix = "enemy_rotten_lesser"
tt.sound_events.death = "EnemyMushroomDeath"
tt.ui.click_rect = r(-15, -5, 30, 30)
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 14)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)
tt.unit.show_blood_pool = false

--沼泽巨人
tt = RT("enemy_swamp_thing", "enemy")
AC(tt, "melee", "ranged", "auras")
anchor_y = 0.24
anchor_x = 0.5
image_y = 87
image_x = 108
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_swamp_thing_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 200
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = v(40, 0)
tt.health.hp_max = 7000
tt.health.armor = 0.4
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = v(0, 69)
tt.info.i18n_key = "ENEMY_SWAMP_THING"
tt.info.enc_icon = 44
tt.info.portrait = IS_PHONE and "portraits_sc_0068" or "info_portraits_sc_0068"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2.5
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 100
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].damage_radius = 35
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = v(30, 0)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound_hit = "AreaAttack"
tt.motion.max_speed = 0.6 * FPS
tt.ranged.attacks[1].bullet = "bomb_swamp_thing"
tt.ranged.attacks[1].bullet_start_offset = {
	v(adx(66), ady(86))
}
tt.ranged.attacks[1].cooldown = 1 + fts(32)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].ignore_hit_offset = true
tt.ranged.attacks[1].max_range = 165
tt.ranged.attacks[1].min_range = 110
tt.ranged.attacks[1].shoot_time = fts(13)
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_swamp_thing"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = v(50, 54)
tt.ui.click_rect.pos.x = -25
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 30)
tt.unit.mod_offset = v(0, 24)
tt.unit.size = UNIT_SIZE_LARGE

--猛毒爬行者
tt = RT("enemy_spider_rotten", "enemy")
AC(tt, "melee", "timed_attacks")
anchor_y = 0.20967741935483872
anchor_x = 0.5
image_y = 62
image_x = 82
tt.enemy.gold = 40
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = v(34, 0)
tt.health.hp_max = 3250
tt.health.magic_armor = 0.6
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = v(0, 47)
tt.info.portrait = IS_PHONE and "portraits_sc_0065" or "info_portraits_sc_0065"
tt.info.i18n_key = "ENEMY_SPIDER_ROTTEN"
tt.info.enc_icon = 42
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_spider_big.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "SpiderAttack"
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_spider_rotten"
tt.sound_events.death = "DeathEplosion"
tt.timed_attacks.list[1] = E:clone_c("bullet_attack")
tt.timed_attacks.list[1].bullet = "enemy_spider_rotten_egg"
tt.timed_attacks.list[1].max_cooldown = 10
tt.timed_attacks.list[1].max_count = 6
tt.timed_attacks.list[1].min_cooldown = 5
tt.ui.click_rect.size = v(44, 40)
tt.ui.click_rect.pos = v(-22, -1)
tt.unit.blood_color = BLOOD_GREEN
tt.unit.explode_fx = "fx_spider_explode"
tt.unit.hit_offset = v(0, 15)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(adx(40), ady(28))
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_POISON, F_SKELETON)

--腐化幼蛛
tt = RT("enemy_spider_rotten_tiny", "enemy")
AC(tt, "melee")
anchor_y = 0.1875
anchor_x = 0.5
image_y = 32
image_x = 42
tt.enemy.gold = 0
tt.enemy.melee_slot = v(20, 0)
tt.health.hp_max = 80
tt.health.magic_armor = 0.3
tt.health_bar.offset = v(0, 20)
tt.info.portrait = IS_PHONE and "portraits_sc_0066" or "info_portraits_sc_0066"
tt.info.i18n_key = "ENEMY_SPIDERTINY_ROTTEN"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "SpiderAttack"
tt.motion.max_speed = 1.2 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_spider_rotten_tiny"
tt.sound_events.death = "DeathEplosionShortA"
tt.unit.blood_color = BLOOD_GREEN
tt.unit.explode_fx = "fx_spider_explode"
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, ady(5))
tt.unit.mod_offset = v(adx(1), ady(14))
tt.unit.mod_offset = v(adx(18), ady(13))
tt.vis.bans = bor(F_POISON, F_SKELETON)

--腐化树精
tt = RT("enemy_rotten_tree", "enemy")
AC(tt, "melee")
anchor_y = 0.18421052631578946
anchor_x = 0.5
image_y = 76
image_x = 82
tt.enemy.gold = 60
tt.enemy.melee_slot = v(25, 0)
tt.health.armor = 0.8
tt.health.hp_max = 4300
tt.health_bar.offset = v(0, 57)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_ROTTEN_TREE"
tt.info.enc_icon = 43
tt.info.portrait = IS_PHONE and "portraits_sc_0067" or "info_portraits_sc_0067"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(11)
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_rotten_tree"
tt.sound_events.death = "DeathSkeleton"
tt.ui.click_rect.size = v(44, 40)
tt.ui.click_rect.pos = v(-22, -1)
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 16)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.show_blood_pool = false

--巨鼠
tt = RT("enemy_giant_rat", "enemy")
AC(tt, "melee")
anchor_y = 0.275
anchor_x = 0.5
image_y = 40
image_x = 64
tt.enemy.gold = 10
tt.enemy.melee_slot = v(26, 0)
tt.health.hp_max = 100
tt.health_bar.offset = v(0, 26)
tt.info.i18n_key = "ENEMY_GIANT_RAT"
tt.info.enc_icon = 61
tt.info.portrait = IS_PHONE and "portraits_sc_0084" or "info_portraits_sc_0084"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 12
tt.melee.attacks[1].damage_min = 8
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].mod = "mod_poison_giant_rat"
tt.melee.attacks[1].sound_hit = "EnemyBlackburnGiantRat"
tt.melee.attacks[1].sound_hit_args = {
	chance = 0.1
}
tt.motion.max_speed = 1.3950892857142858 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_giant_rat"
tt.sound_events.death = nil
tt.unit.hit_offset = v(0, 14)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 13)

--鼠人
tt = RT("enemy_wererat", "enemy")
AC(tt, "melee")
anchor_y = 0.17647058823529413
anchor_x = 0.5
image_y = 68
image_x = 94
tt.enemy.gold = 25
tt.enemy.melee_slot = v(26, 0)
tt.health.armor = 0.3
tt.health.hp_max = 1650
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = v(0, 47)
tt.info.i18n_key = "ENEMY_WERERAT"
tt.info.enc_icon = 62
tt.info.portrait = IS_PHONE and "portraits_sc_0085" or "info_portraits_sc_0085"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 35
tt.melee.attacks[1].damage_min = 25
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].mod = "mod_wererat_poison"
tt.motion.max_speed = 1.6622340425531914 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_wererat"
tt.sound_events.death = nil
tt.ui.click_rect.size = v(32, 40)
tt.ui.click_rect.pos = v(-16, -1)
tt.unit.hit_offset = v(0, 20)
tt.unit.marker_offset = v(0, 2)
tt.unit.mod_offset = v(0, 22)
tt.unit.size = UNIT_SIZE_MEDIUM

--骷髅
tt = RT("enemy_skeleton", "enemy")
AC(tt, "melee")
anchor_y = 0.2
anchor_x = 0.5
image_y = 38
image_x = 50
tt.enemy.gold = 2
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 420
tt.health_bar.offset = v(0, 30)
tt.info.i18n_key = "ENEMY_SKELETON"
tt.info.enc_icon = 27
tt.info.portrait = IS_PHONE and "portraits_sc_0052" or "info_portraits_sc_0052"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_skeleton"
tt.sound_events.death = "DeathSkeleton"
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 14)
tt.unit.mod_offset = v(adx(25), ady(17))
tt.vis.bans = bor(F_SKELETON, F_POISON, F_POLYMORPH)
tt.unit.show_blood_pool = false

--骷髅骑士
tt = RT("enemy_skeleton_big", "enemy")

AC(tt, "melee")

anchor_y = 0.2
anchor_x = 0.5
image_y = 50
image_x = 58
tt.enemy.gold = 10
tt.enemy.melee_slot = v(23, 0)
tt.health.armor = 0.45
tt.health.hp_max = 840
tt.health_bar.offset = v(0, 39)
tt.info.portrait = IS_PHONE and "portraits_sc_0053" or "info_portraits_sc_0053"
tt.info.i18n_key = "ENEMY_SKELETON_BIG"
tt.info.enc_icon = 28
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_skeleton_big"
tt.sound_events.death = "DeathSkeleton"
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 18)
tt.unit.mod_offset = v(adx(30), ady(22))
tt.vis.bans = bor(F_SKELETON, F_POISON, F_POLYMORPH)
tt.unit.show_blood_pool = false

--僵尸
tt = RT("enemy_zombie", "enemy")

AC(tt, "melee")

anchor_y = 0.22
anchor_x = 0.5
image_y = 48
image_x = 42
tt.enemy.gold = 10
tt.enemy.melee_slot = v(18, 0)
tt.health.armor = 0.4
tt.health.hp_max = 250
tt.health_bar.offset = v(0, 35)
tt.info.i18n_key = "ENEMY_ZOMBIE"
tt.info.enc_icon = 41
tt.info.portrait = IS_PHONE and "portraits_sc_0064" or "info_portraits_sc_0064"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 15
tt.melee.attacks[1].damage_min = 5
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.5 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_zombie"
tt.render.sprites[1].name = "raise"
tt.sound_events.death = "DeathSkeleton"
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 14)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(adx(23), ady(20))
tt.vis.bans = bor(F_SKELETON, F_POISON, F_POLYMORPH)
tt.unit.show_blood_pool = false

--火伊布
tt = RT("enemy_demon_flareon", "enemy")
AC(tt, "melee", "ranged", "death_spawns")
anchor_y = 0.16666666666666666
anchor_x = 0.5
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_flareon_death"
tt.enemy.gold = 20
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 250
tt.health.magic_armor = 0.8
tt.health_bar.offset.y = 34
tt.info.i18n_key = "ENEMY_DEMON_FLAREON"
tt.info.enc_icon = 54
tt.info.portrait = IS_PHONE and "portraits_sc_0076" or "info_portraits_sc_0076"
tt.main_script.insert = scripts.enemy_base_portal.insert
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 25
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 1.2 * FPS
tt.ranged.attacks[1].bullet = "flare_flareon"
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 25)
}
tt.ranged.attacks[1].cooldown = 3 + fts(36)
tt.ranged.attacks[1].hold_advance = false
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].shoot_time = fts(9)
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon_flareon"
tt.render.sprites[1].offset.y = 1
tt.sound_events.death = "DeathPuff"
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 12)
tt.unit.show_blood_pool = false

--恶魔军团
tt = RT("enemy_demon_legion", "enemy")
AC(tt, "melee", "timed_attacks", "death_spawns")
image_y = 86
image_x = 106
anchor_y = 0.1511627906976744
anchor_x = 0.5
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_demon_death"
tt.enemy.gold = 60
tt.enemy.melee_slot = v(23, 0)
tt.health.armor = 0.8
tt.health.hp_max = 666
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset.y = 42
tt.info.i18n_key = "ENEMY_DEMON_LEGION"
tt.info.enc_icon = 56
tt.info.portrait = IS_PHONE and "portraits_sc_0077" or "info_portraits_sc_0077"
tt.main_script.insert = scripts.enemy_base_portal.insert
tt.main_script.update = scripts.enemy_demon_legion.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon_legion"
tt.sound_events.death = "DeathPuff"
tt.timed_attacks.list[1] = E:clone_c("spawn_attack")
tt.timed_attacks.list[1].spawn_time = fts(5)
tt.timed_attacks.list[1].clone_time = fts(31)
tt.timed_attacks.list[1].generation = 2
tt.timed_attacks.list[1].animation = "summon"
tt.timed_attacks.list[1].spawn_animation = "spawn"
tt.timed_attacks.list[1].entity = "enemy_demon_legion"
tt.timed_attacks.list[1].cooldown = 15
tt.timed_attacks.list[1].cooldown_after = 10
tt.timed_attacks.list[1].spawn_offset_nodes = {
	5,
	10
}
tt.timed_attacks.list[1].nodes_limit = 20
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 12)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM

--贪吃魔
tt = RT("enemy_demon_gulaemon", "enemy")
AC(tt, "melee", "timed_actions", "death_spawns")
anchor_y = 0.21296296296296297
anchor_x = 0.5
image_y = 108
image_x = 108
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_gulaemon_death"
tt.enemy.gold = 80
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(28, 0)
tt.health.hp_max = 2500
tt.health.magic_armor = 0.6
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset.y = 68
tt.info.i18n_key = "ENEMY_DEMON_GULAEMON"
tt.info.enc_icon = 53
tt.info.portrait = IS_PHONE and "portraits_sc_0078" or "info_portraits_sc_0078"
tt.main_script.insert = scripts.enemy_base_portal.insert
tt.main_script.update = scripts.enemy_demon_gulaemon.update
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 80
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix_ground = "enemy_demon_gulaemon"
tt.render.sprites[1].prefix_air = "enemy_demon_gulaemon_fly"
tt.render.sprites[1].prefix = tt.render.sprites[1].prefix_ground
tt.render.sprites[1].angles.takeoff = {
	"initFlyRightLeft",
	"initFlyUp",
	"initFlyDown"
}
tt.render.sprites[1].angles.land = {
	"endFlyRightLeft",
	"endFlyUp",
	"endFlyDown"
}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "Inferno_FatDemon_0178"
tt.render.sprites[2].offset = v(0.5, 30)
tt.render.sprites[2].z = Z_DECALS
tt.sound_events.death = "DeathPuff"
tt.timed_actions.list[1] = CC("mod_attack")
tt.timed_actions.list[1].cooldown = 15
tt.timed_actions.list[1].charge_time = fts(3)
tt.timed_actions.list[1].mod = "mod_gulaemon_fly"
tt.timed_actions.list[1].nodes_limit_start = 30
tt.timed_actions.list[1].off_health_bar_y = 17
tt.timed_actions.list[1].off_click_rect_y = 24
tt.timed_actions.list[1].off_mod_offset_y = 23
tt.timed_actions.list[1].off_hit_offset_y = 23
tt.timed_actions.list[1].flags_air = bor(F_FLYING)
tt.timed_actions.list[1].bans_air = bor(F_BLOCK, F_THORN)
tt.ui.click_rect = r(-20, 0, 40, 56)
tt.unit.can_explode = false
tt.unit.can_disintegrate = true
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 30)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 20)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM

--死灵法师
tt = RT("enemy_necromancer", "enemy")

AC(tt, "melee", "ranged", "timed_actions")

anchor_y = 0.2
anchor_x = 0.5
image_y = 38
image_x = 44
tt.enemy.gold = 50
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 1200
tt.health_bar.offset = v(0, 30)
tt.info.i18n_key = "ENEMY_NECROMANCER"
tt.info.enc_icon = 29
tt.info.portrait = IS_PHONE and "portraits_sc_0054" or "info_portraits_sc_0054"
tt.main_script.update = scripts.enemy_necromancer.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(10)
tt.motion.max_speed = 0.6 * FPS
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].bullet = "bolt_necromancer"
tt.ranged.attacks[1].bullet_start_offset = {
	v(-8, 22)
}
tt.ranged.attacks[1].cooldown = 1 + fts(23)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 145
tt.ranged.attacks[1].min_range = 60
tt.ranged.attacks[1].shoot_time = fts(9)
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_necromancer"
tt.sound_events.death = "DeathPuff"
tt.timed_actions.list[1] = E:clone_c("spawn_attack")
tt.timed_actions.list[1].cooldown = 8
tt.timed_actions.list[1].spawn_time = fts(12)
tt.timed_actions.list[1].spawn_delay = fts(4)
tt.timed_actions.list[1].entity_chances = {
	0.5,
	1
}
tt.timed_actions.list[1].entity_names = {
	"enemy_skeleton_big",
	"enemy_skeleton"
}
tt.timed_actions.list[1].animation = "summon"
tt.timed_actions.list[1].spawn_animation = "raise"
tt.timed_actions.list[1].max_count = 5
tt.timed_actions.list[1].count_group_name = "necromancer_skeletons"
tt.timed_actions.list[1].count_group_type = COUNT_GROUP_CONCURRENT
tt.timed_actions.list[1].count_group_max = 35
tt.timed_actions.list[1].summon_offsets = {
	{
		2,
		0,
		0
	},
	{
		3,
		0,
		0
	},
	{
		1,
		3,
		8
	},
	{
		2,
		3,
		8
	},
	{
		3,
		3,
		8
	},
	{
		1,
		-3,
		-8
	},
	{
		2,
		-3,
		-8
	},
	{
		3,
		-3,
		-8
	}
}
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 15)
tt.unit.mod_offset = v(adx(23), ady(17))
tt = RT("enemy_skeleton_blackburn", "enemy_skeleton")
tt = RT("enemy_zombie_blackburn", "enemy_halloween_zombie")
tt = RT("enemy_skeleton_warrior", "enemy_skeleton_big")
tt = RT("enemy_demon_cerberus", "enemy")

--地狱犬
AC(tt, "melee", "death_spawns")
anchor_y = 0.14285714285714285
anchor_x = 0.5
image_y = 70
image_x = 128
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_demon_cerberus_death"
tt.death_spawns.delay = 0.11
tt.enemy.gold = 350
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = v(41, 0)
tt.health.armor = 0.8
tt.health.hp_max = 6000
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = v(0, 57)
tt.info.i18n_key = "ENEMY_DEMON_CERBERUS"
tt.info.enc_icon = 55
tt.info.portrait = IS_PHONE and "portraits_sc_0079" or "info_portraits_sc_0079"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_demon_cerberus.update
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 90
tt.melee.attacks[1].damage_min = 70
tt.melee.attacks[1].damage_radius = 57.6
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].dodge_time = fts(7)
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].hit_offset = v(20, 0)
tt.motion.max_speed = 1.3 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon_cerberus"
tt.sound_events.death = "DeathPuff"
tt.sound_events.death_by_explosion = "DeathPuff"
tt.ui.click_rect.size = v(45, 43)
tt.ui.click_rect.pos = v(-22.5, 2)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 25)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_STUN, F_TELEPORT, F_THORN, F_POLYMORPH, F_DISINTEGRATED, F_INSTAKILL)
tt.vis.flags = bor(F_ENEMY, F_BOSS, F_MINIBOSS)

--女巫
tt = RT("enemy_witch", "enemy")
AC(tt, "ranged")
anchor_y = 0.05319148936170213
anchor_x = 0.5
image_y = 94
image_x = 88
tt.enemy.gold = 80
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(26, 0)
tt.health.hp_max = 600
tt.health.magic_armor = 0.9
tt.health_bar.offset = v(0, 72)
tt.info.i18n_key = "ENEMY_WITCH"
tt.info.enc_icon = 66
tt.info.portrait = IS_PHONE and "portraits_sc_0090" or "info_portraits_sc_0090"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_mixed.update
tt.motion.max_speed = 1.4960106382978726 * FPS
tt.ranged.attacks[1].bullet = "bolt_witch"
tt.ranged.attacks[1].bullet_start_offset = {
	v(13, 45)
}
tt.ranged.attacks[1].cooldown = fts(60) + fts(34)
tt.ranged.attacks[1].hold_advance = false
tt.ranged.attacks[1].max_range = 319.1489361702128
tt.ranged.attacks[1].min_range = 35.46099290780142
tt.ranged.attacks[1].shoot_time = fts(23)
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_witch"
tt.sound_events.death = "EnemyBlackburnWitchDeath"
tt.sound_events.insert = "EnemyBlackburnWitch"
tt.ui.click_rect = r(-14, 30, 30, 32)
tt.unit.can_explode = false
tt.unit.can_disintegrate = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 45)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 47)
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_THORN)
tt.vis.flags = bor(F_ENEMY, F_FLYING)

--死魂骑士
tt = RT("enemy_spectral_knight", "enemy")
AC(tt, "melee", "auras")
image_y = 94
image_x = 128
anchor_y = 0.1595744680851064
anchor_x = 0.5
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].cooldown = 0
tt.auras.list[1].name = "aura_spectral_knight"
tt.enemy.gold = 40
tt.enemy.melee_slot = v(26, 0)
tt.health.armor = 1
tt.health.hp_max = 1400
tt.health.immune_to = bor(DAMAGE_PHYSICAL, DAMAGE_EXPLOSION, DAMAGE_ELECTRICAL)
tt.health_bar.offset = v(0, 61)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_SPECTRAL_KNIGHT"
tt.info.enc_icon = 64
tt.info.portrait = IS_PHONE and "portraits_sc_0088" or "info_portraits_sc_0088"
tt.main_script.insert = scripts.enemy_spectral_knight.insert
tt.main_script.update = scripts.enemy_spectral_knight.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 76
tt.melee.attacks[1].damage_min = 24
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 0.775709219858156 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_spectral_knight"
tt.sound_events.death = nil
tt.sound_events.insert = "CBSpectralKnight"
tt.sound_events.insert_args = {
	delay = 0.5
}
tt.ui.click_rect = r(-20, 0, 40, 45)
tt.unit.blood_color = BLOOD_NONE
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 20)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 21)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_THORN)
tt.vis.flags = bor(F_ENEMY)
tt = RT("enemy_spectral_knight_spawn", "enemy_spectral_knight")
tt.enemy.gold = 0

--堕落骑士
tt = RT("enemy_fallen_knight", "enemy")
AC(tt, "melee", "death_spawns")
anchor_y = 0.1595744680851064
anchor_x = 0.5
image_y = 94
image_x = 128
tt.death_spawns.name = "enemy_spectral_knight_spawn"
tt.death_spawns.spawn_animation = "raise"
tt.death_spawns.delay = fts(11)
tt.enemy.gold = 40
tt.enemy.melee_slot = v(26, 0)
tt.health.dead_lifetime = 1
tt.health.hp_max = 1800
tt.health.magic_armor = 0.9
tt.health_bar.offset = v(0, 56)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_FALLEN_KNIGHT"
tt.info.enc_icon = 63
tt.info.portrait = IS_PHONE and "portraits_sc_0087" or "info_portraits_sc_0087"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 76
tt.melee.attacks[1].damage_min = 24
tt.melee.attacks[1].hit_time = fts(13)
tt.motion.max_speed = 0.44326241134751776 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_fallen_knight"
tt.sound_events.death = nil
tt.sound_events.death_by_explosion = nil
tt.ui.click_rect = r(-15, 0, 30, 45)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 20)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 19)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM

--巨魔先锋
tt = RT("enemy_troll_skater", "enemy")
AC(tt, "melee", "auras")
anchor_y = 0.18
anchor_x = 0.5
image_y = 50
image_x = 82
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_troll_skater_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 30
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 350
tt.info.i18n_key = "ENEMY_TROLL_SKATER"
tt.info.enc_icon = 50
tt.info.portrait = IS_PHONE and "portraits_sc_0073" or "info_portraits_sc_0073"
tt.main_script.update = scripts.enemy_troll_skater.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 70
tt.melee.attacks[1].damage_min = 30
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 1.2 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_troll_skater"
tt.sound_events.death = "DeathTroll"
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 13)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 13)
tt.skate = {
	mod = "mod_troll_skater",
	vis_bans_extra = bor(F_BLOCK),
	prefix = "enemy_troll",
	walk_angles = {
		"skateRightLeft",
		"skateUp",
		"skateDown"
	}
}

--哥布林投弹手（需查证）
tt = RT("enemy_hobgoblin", "enemy")
AC(tt, "melee", "death_spawns")
anchor_y = 0.17532467532467533
anchor_x = 0.5
image_y = 154
image_x = 224
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "fx_coin_shower"
tt.death_spawns.offset = v(0, 60)
tt.enemy.gold = 250
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(40, 0)
tt.health.hp_max = 2000
tt.health_bar.offset = v(0, 82)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.i18n_key = "ENEMY_ENDLESS_MINIBOSS_ORC"
tt.info.portrait = IS_PHONE and "portraits_sc_0094" or "info_portraits_sc_0094"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 90
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].damage_radius = 45
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_hobgoblin_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_hobgoblin_ground_hit"
tt.melee.attacks[1].hit_offset = v(72, -9)
tt.melee.attacks[1].hit_time = fts(24)
tt.melee.attacks[1].sound = "AreaAttack"
tt.melee.attacks[1].sound_args = {
	delay = fts(24)
}
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_hobgoblin"
tt.sound_events.death = "DeathJuggernaut"
tt.ui.click_rect = r(-30, 0, 60, 70)
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 34)
tt.unit.mod_offset = v(0, 34)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH, F_DISINTEGRATED, F_INSTAKILL)
tt.vis.flags = bor(F_ENEMY, F_BOSS, F_MINIBOSS)

--Boss 毁灭者
tt = RT("eb_juggernaut", "boss")
AC(tt, "melee", "timed_attacks")
anchor_y = 0.08
anchor_x = 0.5
image_y = 128
image_x = 144
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(40, 0)
tt.health.dead_lifetime = 10
tt.health.hp_max = 10000
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.health_bar.offset = v(0, ady(120))
tt.info.fn = scripts.eb_juggernaut.get_info
tt.info.i18n_key = "ENEMY_JUGGERNAUT"
tt.info.enc_icon = 32
tt.info.portrait = IS_PHONE and "portraits_sc_0027" or "info_portraits_sc_0027"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_juggernaut.update
tt.motion.max_speed = 0.4 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.08)
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {
		"walkingRightLeft",
		"walkingUp",
		"walkingDown"
	}
}
tt.render.sprites[1].prefix = "eb_juggernaut"
tt.sound_events.death = "DeathJuggernaut"
tt.sound_events.insert = "MusicBossFight"
tt.ui.click_rect = r(-35, 0, 70, 80)
tt.unit.blood_color = BLOOD_GRAY
tt.unit.hit_offset = v(0, ady(50))
tt.unit.mod_offset = v(adx(70), ady(50))
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 250
tt.melee.attacks[1].damage_min = 150
tt.melee.attacks[1].damage_radius = 45
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].hit_offset = tt.enemy.melee_slot
tt.melee.attacks[1].hit_fx = "fx_juggernaut_smoke"
tt.melee.attacks[1].sound_hit = "juggernaut_punch"
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "shoot"
tt.timed_attacks.list[1].bullet = "missile_juggernaut"
tt.timed_attacks.list[1].bullet_start_offset = v(-30, 82)
tt.timed_attacks.list[1].cooldown = 11
tt.timed_attacks.list[1].launch_vector = v(12, 170)
tt.timed_attacks.list[1].max_range = 99999
tt.timed_attacks.list[1].min_range = 100
tt.timed_attacks.list[1].shoot_time = fts(24)
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[2] = table.deepclone(tt.timed_attacks.list[1])
tt.timed_attacks.list[2].bullet = "bomb_juggernaut"
tt.timed_attacks.list[2].cooldown = 4

--Boss 大雪怪
tt = RT("eb_jt", "boss")
AC(tt, "melee", "timed_attacks", "auras")
anchor_y = 0.19
anchor_x = 0.5
image_y = 200
image_x = 260
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "jt_spawner_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(55, 0)
tt.health.dead_lifetime = 100
tt.health.hp_max = 11000
tt.health.on_damage = scripts.eb_jt.on_damage
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.health_bar.offset = v(0, ady(172))
tt.info.fn = scripts.eb_jt.get_info
tt.info.i18n_key = "ENEMY_YETI_BOSS"
tt.info.enc_icon = 33
tt.info.portrait = IS_PHONE and "portraits_sc_0047" or "info_portraits_sc_0047"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_jt.update
tt.motion.max_speed = 0.4 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.08)
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {
		"walkingRightLeft",
		"walkingUp",
		"walkingDown"
	}
}
tt.render.sprites[1].prefix = "eb_jt"
tt.tap_decal = "decal_jt_tap"
tt.tap_timeout = 1.5
tt.sound_events.death = "JtDeath"
tt.sound_events.death_explode = "JtExplode"
tt.sound_events.insert = "MusicBossFight"
tt.ui.click_rect = r(-38, 0, 76, 95)
tt.unit.hit_offset = v(0, 60)
tt.unit.marker_hidden = true
tt.unit.mod_offset = v(adx(130), ady(90))
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].count = 5
tt.melee.attacks[1].damage_max = 200
tt.melee.attacks[1].damage_min = 150
tt.melee.attacks[1].damage_radius = 45
tt.melee.attacks[1].damage_type = DAMAGE_EAT
tt.melee.attacks[1].hit_offset = tt.enemy.melee_slot
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound = "JtEat"
tt.melee.attacks[1].sound_args = {
	delay = fts(6)
}
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].cooldown = 10 + fts(29)
tt.timed_attacks.list[1].count = 4
tt.timed_attacks.list[1].exhausted_duration = 4
tt.timed_attacks.list[1].exhausted_sound = "JtRest"
tt.timed_attacks.list[1].exhausted_sound_args = {
	delay = fts(34)
}
tt.timed_attacks.list[1].hit_decal = "decal_jt_ground_hit"
tt.timed_attacks.list[1].hit_offset = v(80, -10)
tt.timed_attacks.list[1].hit_time = fts(16)
tt.timed_attacks.list[1].max_range = 192
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].mod = "mod_jt_tower"
tt.timed_attacks.list[1].sound = "JtAttack"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(6)
}

--Boss 卫兹南
tt = RT("eb_veznan", "boss")
AC(tt, "melee", "timed_attacks", "taunts")
anchor_y = 0.17010309278350516
anchor_x = 0.5
image_y = 194
image_x = 214
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(20, 0)
tt.health.hp_max = {
	53333,
	66666,
	79999
}
tt.health.on_damage = scripts.eb_veznan.on_damage
tt.health.ignore_damage = true
tt.health_bar.hidden = true
tt.health_bar.offset = v(0, 43)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.info.i18n_key = "ENEMY_VEZNAN"
tt.info.enc_icon = 34
tt.info.portrait = IS_PHONE and "portraits_sc_0056" or "info_portraits_sc_0056"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_veznan.update
tt.motion.max_speed = 0.4 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_veznan"
tt.render.sprites[1].name = "idleDown"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {
		"walkingRightLeft",
		"walkingUp",
		"walkingDown"
	}
}
tt.sound_events.death = "VeznanDeath"
tt.ui.click_rect = r(-11, -2, 22, 38)
tt.unit.hit_offset = v(0, 14)
tt.unit.mod_offset = v(0, 12)
tt.unit.marker_offset = v(0, 0)
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH, F_ALL)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.pos_castle = v(518, 677)
tt.souls_aura = "veznan_souls_aura"
tt.white_circle = "decal_eb_veznan_white_circle"
tt.taunts.animation = "laught"
tt.taunts.delay_min = fts(400)
tt.taunts.delay_max = fts(700)
tt.taunts.duration = 4
tt.taunts.decal_name = "decal_s12_shoutbox"
tt.taunts.offset = v(0, 0)
tt.taunts.pos = v(525, 608)
tt.taunts.sets.welcome = CC("taunt_set")
tt.taunts.sets.welcome.format = "VEZNAN_TAUNT_%04d"
tt.taunts.sets.welcome.end_idx = 5
tt.taunts.sets.welcome.delays = {
	fts(60),
	fts(140),
	fts(450),
	fts(250)
}
tt.taunts.sets.castle = CC("taunt_set")
tt.taunts.sets.castle.format = "VEZNAN_TAUNT_%04d"
tt.taunts.sets.castle.start_idx = 6
tt.taunts.sets.castle.end_idx = 25
tt.taunts.sets.damage = CC("taunt_set")
tt.taunts.sets.damage.format = "VEZNAN_TAUNT_%04d"
tt.taunts.sets.damage.start_idx = 26
tt.taunts.sets.damage.end_idx = 29
tt.taunts.sets.pre_battle = CC("taunt_set")
tt.taunts.sets.pre_battle.format = "VEZNAN_TAUNT_%04d"
tt.taunts.sets.pre_battle.start_idx = 30
tt.taunts.sets.pre_battle.end_idx = 30
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].count = 8
tt.melee.attacks[1].damage_min = 666
tt.melee.attacks[1].damage_max = 999
tt.melee.attacks[1].damage_radius = 75
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_offset = v(-10, -2)
tt.melee.attacks[1].hit_time = fts(17)
tt.melee.attacks[1].hit_decal = "decal_veznan_strike"
tt.melee.attacks[1].sound_hit = "VeznanAttack"
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].cooldown = 2.5
tt.melee.attacks[2].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].hit_decal = nil
tt.melee.attacks[2].hit_fx = "fx_veznan_demon_fire"
tt.melee.attacks[2].hit_fx_offset = v(20, 9)
tt.melee.attacks[2].hit_fx_once = true
tt.melee.attacks[2].hit_fx_flip = true
tt.melee.attacks[2].hit_times = {
	fts(20),
	fts(24),
	fts(28),
	fts(32),
	fts(36),
	fts(38),
	fts(42),
	fts(44)
}
tt.melee.attacks[2].hit_offset = v(40, 0)
tt.melee.attacks[2].sound_hit = nil
tt.melee.attacks[2].sound = "VeznanDemonFire"
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].cooldown = 13
tt.timed_attacks.list[1].animation = "spellDown"
tt.timed_attacks.list[1].hit_time = fts(14)
tt.timed_attacks.list[1].mod = "mod_veznan_tower"
tt.timed_attacks.list[1].sound = "VeznanHoldCast"
tt.timed_attacks.list[1].attack_duration = fts(44)
tt.timed_attacks.list[1].data = {
	[9] = {
		13,
		2
	},
	[10] = {
		13,
		3
	},
	[11] = {
		14,
		4
	},
	[12] = {
		14,
		5
	},
	[13] = {
		16,
		6
	},
	[14] = {
		16,
		7
	},
	[15] = {
		18,
		8
	}
}
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animation = "spellDown"
tt.timed_attacks.list[2].cooldown = 15
tt.timed_attacks.list[2].hit_time = fts(14)
tt.timed_attacks.list[2].portal_name = "veznan_portal"
tt.timed_attacks.list[2].sound = "VeznanPortalSummon"
tt.timed_attacks.list[2].attack_duration = fts(44)
tt.timed_attacks.list[2].data = {
	[6] = {
		15,
		3,
		{
			1,
			0,
			0
		}
	},
	[7] = {
		10,
		2,
		{
			1,
			0,
			0
		}
	},
	[8] = {
		20,
		3,
		{
			0,
			1,
			0
		}
	},
	[9] = {
		15,
		3,
		{
			1,
			0,
			0
		}
	},
	[10] = {
		20,
		3,
		{
			1,
			1,
			0
		}
	},
	[11] = {
		15,
		3,
		{
			1,
			1,
			0
		}
	},
	[12] = {
		15,
		3,
		{
			1,
			1,
			0
		}
	},
	[13] = {
		15,
		3,
		{
			0,
			0,
			1
		}
	},
	[14] = {
		15,
		3,
		{
			1,
			1,
			1
		}
	},
	[15] = {
		15,
		3,
		{
			1,
			1,
			1
		}
	}
}
tt.battle = {
	ba_animation = "spell",
	pa_animation = "spell",
	pa_cooldown = 10,
	pa_max_count = 40
}
tt.demon = {
	health_bar_offset = v(0, 118),
	health_bar_scale = 1.8,
	melee_slot = v(50, 0),
	speed = 0.6 * FPS,
	sprites_prefix = "eb_veznan_demon",
	transform_sound = "VeznanToDemon",
	ui_click_rect = r(-25, -5, 50, 110),
	unit_hit_offset = v(0, 55),
	unit_mod_offset = v(0, 45),
	unit_size = UNIT_SIZE_LARGE,
	info_portrait = IS_PHONE and "portraits_sc_0056" or "info_portraits_sc_0093"
}

--Boss 萨雷格兹
tt = RT("eb_sarelgaz", "boss")
AC(tt, "melee")
anchor_y = 0.1484375
anchor_x = 0.5
image_y = 128
image_x = 220
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(80, 0)
tt.health.dead_lifetime = 8
tt.health.hp_max = 120000
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.health_bar.offset = v(0, 108)
tt.info.i18n_key = "ENEMY_SARELGAZ"
tt.info.enc_icon = 35
tt.info.portrait = IS_PHONE and "portraits_sc_0057" or "info_portraits_sc_0057"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 500
tt.melee.attacks[1].damage_min = 300
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].damage_type = DAMAGE_EAT
tt.melee.attacks[1].sound = "SpiderAttack"
tt.motion.max_speed = 0.4 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_sarelgaz"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {
		"walkingRightLeft",
		"walkingUp",
		"walkingDown"
	}
}
tt.sound_events.death = "DeathEplosion"
tt.sound_events.insert = "MusicBossFight"
tt.ui.click_rect = r(-45, 0, 90, 80)
tt.unit.blood_color = BLOOD_GREEN
tt.unit.can_explode = false
tt.unit.can_disintegrate = false
tt.unit.fade_time_after_death = 2
tt.unit.hit_offset = v(0, 45)
tt.unit.marker_hidden = true
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 45)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)

--Boss吉拉克
tt = RT("eb_gulthak", "boss")
AC(tt, "melee", "timed_attacks")
anchor_y = 0.11
anchor_x = 0.5
tt.enemy.gold = 0
image_y = 196
image_x = 340
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(60, 0)
tt.health.dead_lifetime = 8
tt.health.hp_max = 120000
tt.health_bar.offset = v(0, 95)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.i18n_key = "ENEMY_BOSS_GOBLIN_CHIEFTAIN"
tt.info.enc_icon = 40
tt.info.portrait = IS_PHONE and "portraits_sc_0063" or "info_portraits_sc_0063"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_shaman.update
tt.melee.attacks[1].cooldown = 1 + fts(20)
tt.melee.attacks[1].damage_max = 600
tt.melee.attacks[1].damage_min = 200
tt.melee.attacks[1].hit_time = fts(11)
tt.motion.max_speed = 0.4 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_gulthak"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles_flip_vertical = {
	walk = true
}
tt.render.sprites[1].angles = {
	walk = {
		"walkingRightLeft",
		"walkingUp",
		"walkingDown"
	}
}
tt.sound_events.death = "DeathBig"
tt.sound_events.insert = "MusicBossFight"
tt.ui.click_rect = r(-50, 0, 90, 60)
tt.unit.can_explode = false
tt.unit.can_disintegrate = false
tt.unit.fade_time_after_death = 2
tt.unit.hit_offset = v(0, 30)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 27)
tt.unit.marker_hidden = true
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].animation = "heal"
tt.timed_attacks.list[1].cast_time = fts(14)
tt.timed_attacks.list[1].cooldown = 8
tt.timed_attacks.list[1].max_count = 20
tt.timed_attacks.list[1].max_range = 320
tt.timed_attacks.list[1].mod = "mod_gulthak_heal"
tt.timed_attacks.list[1].sound = "EnemyHealing"
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)

--Boss 绿泥树怪
tt = RT("eb_greenmuck", "boss")
AC(tt, "melee", "timed_attacks")
anchor_y = 0.1402439024390244
anchor_x = 0.5
image_y = 232
image_x = 244
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(40, 0)
tt.health.dead_lifetime = 8
tt.health.hp_max = 80000
tt.health_bar.offset = v(0, 135)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.fn = scripts.eb_greenmuck.get_info
tt.info.i18n_key = "ENEMY_ROTTEN_TREE_BOSS"
tt.info.enc_icon = 45
tt.info.portrait = IS_PHONE and "portraits_sc_0069" or "info_portraits_sc_0069"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_greenmuck.update
tt.motion.max_speed = 0.3 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_greenmuck"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {
		"walkingRightLeft",
		"walkingUp",
		"walkingDown"
	}
}
tt.sound_events.death = nil
tt.sound_events.insert = "MusicBossFight"
tt.ui.click_rect = r(-30, 0, 60, 110)
tt.unit.blood_color = BLOOD_GRAY
tt.unit.fade_time_after_death = 2
tt.unit.hit_offset = v(0, 37)
tt.unit.marker_offset = v(0, -10)
tt.unit.marker_hidden = true
tt.unit.mod_offset = v(0, 37)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 250
tt.melee.attacks[1].damage_min = 150
tt.melee.attacks[1].damage_radius = 60
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].hit_offset = tt.enemy.melee_slot
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "shoot"
tt.timed_attacks.list[1].bullet = "bomb_greenmuck"
tt.timed_attacks.list[1].count = 7
tt.timed_attacks.list[1].bullet_start_offset = v(0, 120)
tt.timed_attacks.list[1].cooldown = 6
tt.timed_attacks.list[1].shoot_time = fts(13)
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].vis_bans = F_ENEMY

--Boss 金并
tt = RT("eb_kingpin", "enemy")

AC(tt, "melee", "timed_attacks", "auras")

anchor_y = 0.13
anchor_x = 0.5
image_y = 204
image_x = 218
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "kingpin_damage_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(60, 0)
tt.health.dead_lifetime = 12
tt.health.hp_max = 80000
tt.health_bar.offset = v(0, 125)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.fn = scripts.eb_kingpin.get_info
tt.info.i18n_key = "ENEMY_BOSS_BANDIT"
tt.info.enc_icon = 48
tt.info.portrait = IS_PHONE and "portraits_sc_0072" or "info_portraits_sc_0072"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_kingpin.update
tt.motion.max_speed = 0.4 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.13)
tt.render.sprites[1].prefix = "eb_kingpin"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {
		"walkingRightLeft",
		"walkingUp",
		"walkingDown"
	}
}
tt.sound_events.death = "DeathJuggernaut"
tt.sound_events.insert = "MusicBossFight"
tt.stop_time = 5
tt.stop_cooldown = 5
tt.stop_wait = fts(25)
tt.ui.click_rect = r(-50, 0, 100, 75)
tt.unit.fade_time_after_death = 2
tt.unit.hit_offset = v(0, 80)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 82)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH, F_BLOCK)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1 + fts(20)
tt.melee.attacks[1].damage_max = 100
tt.melee.attacks[1].damage_min = 100
tt.melee.attacks[1].damage_radius = 65
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].hit_offset = tt.enemy.melee_slot
tt.melee.attacks[1].hit_fx = "fx_juggernaut_smoke"
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].animation = "eat"
tt.timed_attacks.list[1].cast_time = fts(14)
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].max_count = 1
tt.timed_attacks.list[1].max_range = 320
tt.timed_attacks.list[1].mod = "mod_kingpin_heal_self"
tt.timed_attacks.list[1].sound = "EnemyHealing"
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)
tt.timed_attacks.list[2] = table.deepclone(tt.timed_attacks.list[1])
tt.timed_attacks.list[2].animation = "heal"
tt.timed_attacks.list[2].max_count = 9999
tt.timed_attacks.list[2].max_range = 100
tt.timed_attacks.list[2].mod = "mod_kingpin_heal_others"

--Boss 阿古可汗
tt = RT("eb_ulgukhai", "boss")

AC(tt, "melee", "auras")

anchor_y = 0.1792452830188679
anchor_x = 0.5
image_y = 150
image_x = 240
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_forest_troll_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(40, 0)
tt.health.dead_lifetime = 12
tt.health.hp_max = 10000
tt.health_bar.offset = v(0, 90)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.fn = scripts.eb_ulgukhai.get_info
tt.info.i18n_key = "ENEMY_TROLL_BOSS"
tt.info.enc_icon = 52
tt.info.portrait = IS_PHONE and "portraits_sc_0075" or "info_portraits_sc_0075"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_ulgukhai.update
tt.motion.max_speed = 0.3 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_ulgukhai"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {
		"walkingRightLeft",
		"walkingUp",
		"walkingDown"
	}
}
tt.sound_events.death = "DeathBig"
tt.sound_events.insert = "MusicBossFight"
tt.unit.blood_color = BLOOD_GRAY
tt.ui.click_rect = r(-25, 5, 50, 65)
tt.unit.fade_time_after_death = 2
tt.unit.hit_offset = v(0, 30)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 26)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.shielded_extra_vis_bans = bor(F_MOD, F_POISON)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 3
tt.melee.attacks[1].damage_max = 350
tt.melee.attacks[1].damage_min = 150
tt.melee.attacks[1].damage_radius = 57.6
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].hit_time = fts(16)
tt.melee.attacks[1].hit_offset = v(60, 0)
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].sound_hit = "AreaAttack"

--Boss 摩洛克
tt = RT("eb_moloch", "boss")
AC(tt, "melee", "timed_attacks")
anchor_y = 0.105
anchor_x = 0.5
image_y = 282
image_x = 282
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(33, 0)
tt.health.dead_lifetime = 100
tt.health.ignore_damage = true
tt.health.hp_max = {
	88889,
	111111,
	133333
}
tt.health_bar.offset = v(0, 125)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.i18n_key = "ENEMY_DEMON_MOLOCH"
tt.info.enc_icon = 57
tt.info.fn = scripts.eb_moloch.get_info
tt.info.portrait = IS_PHONE and "portraits_sc_0080" or "info_portraits_sc_0080"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_moloch.update
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_moloch"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {
		"walkingRightLeft",
		"walkingUp",
		"walkingDown"
	}
}
tt.sound_events.death = "EnemyInfernoBossDeath"
tt.ui.click_rect = r(-25, 0, 50, 100)
tt.unit.hit_offset = v(0, 60)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 45)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_ALL)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.stand_up_wait_time = fts(14)
tt.stand_up_sound = "MusicBossFight"
tt.pos_sitting = v(526, 614)
tt.nav_path.pi = 2
tt.nav_path.spi = 1
tt.nav_path.ni = 1
tt.wave_active = 16
tt.active_vis_bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1.5 + fts(25)
tt.melee.attacks[1].damage_max = 120
tt.melee.attacks[1].damage_min = 80
tt.melee.attacks[1].damage_radius = 40
tt.melee.attacks[1].count = nil
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].hit_offset = tt.enemy.melee_slot
tt.melee.attacks[1].hit_fx = "fx_moloch_ring"
tt.melee.attacks[1].sound_hit = "EnemyInfernoStomp"
tt.timed_attacks.list[1] = CC("area_attack")
tt.timed_attacks.list[1].cooldown = 7
tt.timed_attacks.list[1].animation = "horn_attack"
tt.timed_attacks.list[1].damage_radius = 100
tt.timed_attacks.list[1].damage_type = DAMAGE_INSTAKILL
tt.timed_attacks.list[1].hit_time = fts(15)
tt.timed_attacks.list[1].min_targets = 2
tt.timed_attacks.list[1].fx_list = {
	{
		"fx_moloch_rocks",
		{
			{
				36,
				-30
			},
			{
				1,
				-10
			},
			{
				90,
				-23
			},
			{
				87,
				5
			},
			{
				49,
				-3
			},
			{
				54,
				17
			}
		}
	},
	{
		"fx_moloch_ring",
		{
			{
				45,
				0
			}
		}
	}
}
tt.timed_attacks.list[1].hit_offset = v(20, 0)
tt.timed_attacks.list[1].sound = "EnemyInfernoHorns"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(5)
}

--Boss 麦柯尼德
tt = RT("eb_myconid", "boss")
AC(tt, "melee", "timed_attacks")
anchor_y = 0.16428571428571428
anchor_x = 0.5
image_y = 140
image_x = 174
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(40, 0)
tt.health.dead_lifetime = 12
tt.health.hp_max = 104500
tt.health_bar.offset = v(0, 100)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.fn = scripts.eb_myconid.get_info
tt.info.i18n_key = "ENEMY_ROTTEN_MYCONID"
tt.info.enc_icon = 59
tt.info.portrait = IS_PHONE and "portraits_sc_0082" or "info_portraits_sc_0082"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_myconid.update
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_myconid"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {
		"walkingRightLeft",
		"walkingUp",
		"walkingDown"
	}
}
tt.sound_events.death = "EnemyMushroomBossDeath"
tt.sound_events.insert = "MusicBossFight"
tt.ui.click_rect = r(-25, 0, 50, 80)
tt.unit.fade_time_after_death = 4
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.hit_offset = v(0, 33)
tt.unit.mod_offset = v(0, 33)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.spawner_entity = "myconid_spawner"
tt.on_death_spawn_count = 12
tt.on_death_spawn_wait = fts(40)
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 350
tt.melee.attacks[1].damage_min = 150
tt.melee.attacks[1].hit_time = fts(9)
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "spores"
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].final_wait = fts(20)
tt.timed_attacks.list[1].fx = "fx_myconid_spores"
tt.timed_attacks.list[1].fx_offset = v(0, 40)
tt.timed_attacks.list[1].min_nodes = 25
tt.timed_attacks.list[1].mod = "mod_myconid_poison"
tt.timed_attacks.list[1].radius = 110
tt.timed_attacks.list[1].sound = "EnemyMushroomGas"
tt.timed_attacks.list[1].summon_counts = {
	2,
	3,
	3,
	4,
	4,
	4,
	3,
	2
}
tt.timed_attacks.list[1].vis_bans = F_ENEMY
tt.timed_attacks.list[1].vis_flags = bor(F_MOD, F_POISON)
tt.timed_attacks.list[1].wait_times = {
	fts(15),
	fts(3),
	fts(6)
}

--Boss布莱克本
tt = RT("eb_blackburn", "boss")
AC(tt, "melee", "timed_attacks", "auras")
anchor_y = 0.16993464052287582
anchor_x = 0.5
image_y = 308
image_x = 314
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(40, 0)
tt.health.dead_lifetime = 100
tt.health.armor = 0.75
tt.health.hp_max = 89000
tt.health_bar.offset = v(0, 125)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.fn = scripts.eb_blackburn.get_info
tt.info.i18n_key = "ENEMY_BOSS_BLACKBURN"
tt.info.enc_icon = 69
tt.info.portrait = IS_PHONE and "portraits_sc_0093" or "info_portraits_sc_0092"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_blackburn.update
tt.motion.max_speed = 0.5540780141843972 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_blackburn"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {
		"walkingRightLeft",
		"walkingUp",
		"walkingDown"
	}
}
tt.sound_events.death = "EnemyBlackburnBossDeath"
tt.sound_events.insert = "MusicBossFight"
tt.ui.click_rect.pos.y = 9
tt.unit.hit_offset = v(adx(150), ady(115))
tt.unit.marker_offset = v(0, 11)
tt.unit.mod_offset = v(0, ady(115))
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "blackburn_aura"
tt.auras.list[1].cooldown = 0
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1.3 + fts(40)
tt.melee.attacks[1].damage_max = 200
tt.melee.attacks[1].damage_min = 100
tt.melee.attacks[1].damage_radius = 63.829787234042556
tt.melee.attacks[1].dodge_time = fts(13)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound_hit = "EnemyBlackburnBossSwing"
tt.melee.attacks[1].vis_bans = bor(F_STUN)
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].after_hit_wait = fts(20)
tt.timed_attacks.list[1].animation = "smash"
tt.timed_attacks.list[1].aura_shake = "aura_screen_shake"
tt.timed_attacks.list[1].cooldown = fts(300)
tt.timed_attacks.list[1].after_cooldown = fts(150)
tt.timed_attacks.list[1].damage_max = 5
tt.timed_attacks.list[1].damage_min = 1
tt.timed_attacks.list[1].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[1].damage_radius = 106.38297872340426
tt.timed_attacks.list[1].fx = "fx_blackburn_smash"
tt.timed_attacks.list[1].fx_offset = v(26, 7)
tt.timed_attacks.list[1].hit_decal = "decal_blackburn_smash_ground"
tt.timed_attacks.list[1].hit_time = fts(24)
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].max_range = 283.68794326241135
tt.timed_attacks.list[1].mod = "mod_blackburn_stun"
tt.timed_attacks.list[1].mod_towers = "mod_blackburn_tower"
tt.timed_attacks.list[1].sound = "EnemyBlackburnBossSpecialStomp"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(13)
}
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)
tt = E:register_t("eb_elder_shaman", "decal_scripted")

E:add_comps(tt, "attacks")

tt.attacks.animation = "cast"
tt.attacks.delay = {
	0.6,
	0.9
}
tt.attacks.list[1] = E:clone_c("aura_attack")
tt.attacks.list[1].aura = "aura_elder_shaman_healing"
tt.attacks.list[1].node_offset = {
	10,
	30
}
tt.attacks.list[1].path_margins = {
	40,
	10
}
tt.attacks.list[1].power_name = "healing"
tt.attacks.list[1].vis_bans = bor(F_FLYING, F_BOSS, F_FRIEND)
tt.attacks.list[1].vis_flags = bor(F_MOD)
tt.attacks.list[2] = E:clone_c("aura_attack")
tt.attacks.list[2].aura = "aura_elder_shaman_damage"
tt.attacks.list[2].power_name = "damage"
tt.attacks.list[2].vis_bans = bor(F_FLYING, F_BOSS, F_ENEMY)
tt.attacks.list[2].vis_flags = bor(F_MOD)
tt.attacks.list[2].enemy_vis_bans = bor(F_FLYING, F_BOSS)
tt.attacks.list[2].enemy_vis_flags = bor(F_MOD)
tt.attacks.list[3] = E:clone_c("aura_attack")
tt.attacks.list[3].aura = "aura_elder_shaman_speed"
tt.attacks.list[3].node_offset = {
	10,
	30
}
tt.attacks.list[3].path_margins = {
	25,
	40
}
tt.attacks.list[3].power_name = "speed"
tt.attacks.list[3].vis_bans = bor(F_FLYING, F_BOSS, F_FRIEND)
tt.attacks.list[3].vis_flags = bor(F_MOD)
tt.main_script.update = scripts.eb_elder_shaman.update
tt.render.sprites[1].prefix = "eb_elder_shaman"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.09259259259259259
tt.taunt = {
	delay_min = 15,
	delay_max = 20,
	duration = 4,
	sets = {
		welcome = {},
		prebattle = {},
		battle = {},
		life_lost = {},
		totem = {}
	}
}
tt.taunt.sets.welcome.format = "ENDLESS_BOSS_ORC_TAUNT_WELCOME_%04d"
tt.taunt.sets.welcome.start_idx = 1
tt.taunt.sets.welcome.end_idx = 2
tt.taunt.sets.prebattle.format = "ENDLESS_BOSS_ORC_TAUNT_PREBATTLE_%04d"
tt.taunt.sets.prebattle.start_idx = 1
tt.taunt.sets.prebattle.end_idx = 4
tt.taunt.sets.battle.format = "ENDLESS_BOSS_ORC_TAUNT_GENERIC_%04d"
tt.taunt.sets.battle.start_idx = 1
tt.taunt.sets.battle.end_idx = 9
tt.taunt.sets.life_lost.format = "ENDLESS_BOSS_ORC_TAUNT_LIFE_LOST_%04d"
tt.taunt.sets.life_lost.start_idx = 1
tt.taunt.sets.life_lost.end_idx = 1
tt.taunt.sets.totem.format = "ENDLESS_BOSS_ORC_TAUNT_TOTEM_%04d"
tt.taunt.sets.totem.start_idx = 1
tt.taunt.sets.totem.end_idx = 1
tt.taunt.offset = v(0, -75)
tt.taunt.ts = 0
tt.taunt.next_ts = 0
tt = RT("decal_elder_shaman_shoutbox", "decal_tween")

AC(tt, "texts")

tt.render.sprites[1].name = "HalloweenBoss_tauntBox"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[2].offset = v(0, -9)
tt.texts.list[1].text = "Hello world"
tt.texts.list[1].size = v(172, 62)
tt.texts.list[1].font_name = "body_bold"
tt.texts.list[1].font_size = 20
tt.texts.list[1].color = {
	255,
	114,
	114
}
tt.texts.list[1].line_height = 0.8
tt.texts.list[1].sprite_id = 2
tt.texts.list[1].fit_height = true
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {
	{
		0,
		v(1.01, 1.01)
	},
	{
		0.4,
		v(0.99, 0.99)
	},
	{
		0.8,
		v(1.01, 1.01)
	}
}
tt.tween.props[1].sprite_id = 1
tt.tween.props[1].loop = true
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].keys = {
	{
		0,
		0
	},
	{
		0.25,
		255
	}
}
tt.tween.props[3].sprite_id = 1
tt.tween.props[4] = table.deepclone(tt.tween.props[3])
tt.tween.props[4].sprite_id = 2
tt.tween.remove = false
tt = RT("spear_legionnaire", "arrow")
tt.bullet.damage_min = 24
tt.bullet.damage_max = 40
tt.bullet.flight_time = fts(20)
tt.bullet.miss_decal = "decal_spear"
tt.render.sprites[1].name = "spear"
tt.sound_events.insert = "AxeSound"
tt = RT("arrow_1", "arrow")
tt.bullet.damage_min = 4
tt.bullet.damage_max = 6
tt = RT("arrow_2", "arrow")
tt.bullet.damage_min = 7
tt.bullet.damage_max = 11
tt = RT("arrow_3", "arrow")
tt.bullet.damage_min = 10
tt.bullet.damage_max = 16
tt = RT("arrow_ranger", "arrow")
tt.bullet.damage_min = 13*1.5
tt.bullet.damage_max = 19*1.5
tt = RT("axe_barbarian", "arrow")
tt.bullet.damage_min = 24
tt.bullet.damage_max = 32
tt.bullet.damage_inc = 10
tt.bullet.flight_time = fts(23)
tt.bullet.rotation_speed = 30 * FPS * math.pi / 180
tt.bullet.miss_decal = "decal_axe"
tt.bullet.reset_to_target_pos = true
tt.main_script.insert = scripts.axe_barbarian.insert
tt.render.sprites[1].name = "barbarian_axe_0001"
tt.render.sprites[1].animated = false
tt.bullet.pop = nil
tt.sound_events.insert = "AxeSound"
tt = RT("arrow_elf", "arrow")
tt.bullet.damage_min = 25
tt.bullet.damage_max = 50
tt.bullet.flight_time = fts(15)
tt = RT("arrow_shadow_archer", "arrow")
tt.bullet.damage_min = 20
tt.bullet.damage_max = 30
tt = RT("arrow_hero_alleria", "arrow")
tt.bullet.xp_gain_factor = 2.875
tt.bullet.prediction_error = false
tt = E:register_t("arrow_multishot_hero_alleria", "arrow")
tt.bullet.particles_name = "ps_arrow_multishot_hero_alleria"
tt.bullet.damage_min = 150
tt.bullet.damage_max = 250
tt.bullet.damage_true = DAMAGE_TRUE
tt.bullet.prediction_error = false
tt.extra_arrows_range = 100
tt.extra_arrows = 3
tt.main_script.insert = scripts.arrow_multishot_hero_alleria.insert
tt.render.sprites[1].name = "hero_archer_arrow"
tt = RT("axe_troll_axe_thrower", "arrow")
tt.bullet.damage_min = 40
tt.bullet.damage_max = 80
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.flight_time = fts(23)
tt.bullet.rotation_speed = 30 * FPS * math.pi / 180
tt.bullet.miss_decal = "troll_axethrower_proyectiles_0002"
tt.bullet.reset_to_target_pos = true
tt.render.sprites[1].name = "troll_axethrower_proyectiles_0001"
tt.render.sprites[1].animated = false
tt.bullet.pop = nil
tt.sound_events.insert = "AxeSound"
tt = RT("ball_raider", "arrow")
tt.bullet.damage_min = 80
tt.bullet.damage_max = 120
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.flight_time = fts(23)
tt.bullet.rotation_speed = 30 * FPS * math.pi / 180
tt.bullet.miss_decal = "RaiderBall_0002"
tt.bullet.reset_to_target_pos = true
tt.render.sprites[1].name = "RaiderBall_0001"
tt.render.sprites[1].animated = false
tt.bullet.pop = nil
tt.sound_events.insert = "AxeSound"
tt = RT("flare_flareon", "arrow")
tt.bullet.damage_max = 30
tt.bullet.damage_min = 20
tt.bullet.flight_time = fts(16)
tt.bullet.hit_blood_fx = nil
tt.bullet.miss_decal = nil
tt.bullet.miss_fx = "fx_explosion_flareon_flare"
tt.bullet.mod = "mod_flareon_burn"
tt.bullet.particles_name = "ps_flare_flareon"
tt.bullet.pop = nil
tt.render.sprites[1].name = "demon_flareon_flare"
tt.render.sprites[1].animated = true
tt = RT("bolt_1", "bolt")
tt.bullet.damage_min = 9
tt.bullet.damage_max = 17
tt = RT("bolt_2", "bolt")
tt.bullet.damage_min = 23
tt.bullet.damage_max = 43
tt = RT("bolt_3", "bolt")
tt.bullet.damage_min = 40
tt.bullet.damage_max = 74
tt = RT("bolt_sorcerer", "bolt")
tt.bullet.damage_max = 78
tt.bullet.damage_min = 42
tt.bullet.hit_fx = "fx_bolt_sorcerer_hit"
tt.bullet.max_speed = 600
tt.bullet.mods = {
	"mod_sorcerer_curse_dps",
	"mod_sorcerer_curse_armor"
}
tt.bullet.particles_name = "ps_bolt_sorcerer"
tt.bullet.pop = {
	"pop_zap_sorcerer"
}
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].prefix = "bolt_sorcerer"
tt.sound_events.insert = "BoltSorcererSound"
tt = RT("bolt_necromancer", "bolt_enemy")
tt.bullet.align_with_trajectory = true
tt.bullet.damage_max = 40
tt.bullet.damage_min = 20
tt.bullet.hit_fx = "fx_bolt_necromancer_hit"
tt.bullet.max_speed = 450
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].prefix = "bolt_necromancer"
tt.sound_events.insert = "BoltSorcererSound"
tt = RT("bolt_witch", "bolt_enemy")
tt.bullet.damage_max = 60
tt.bullet.damage_min = 40
tt.bullet.hit_fx = "fx_bolt_witch_hit"
tt.bullet.min_speed = 450
tt.bullet.max_speed = 750
tt.bullet.mod = "mod_witch_frog"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].prefix = "bolt_witch"
tt.sound_events.insert = "kr4_tower_wickedsisters_attack_v1"
tt = E:register_t("hammer_hero_thor", "bolt")
tt.bullet.acceleration_factor = 0.05
tt.bullet.min_speed = 300
tt.bullet.max_speed = 900
tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = 0
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.hit_blood_fx = nil
tt.bullet.hit_fx = nil
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.mod = "mod_hero_thor_thunderclap"
tt.bullet.pop = nil
tt.render.sprites[1].prefix = "hammer_hero_thor"
tt.sound_events.insert = nil
tt = RT("bolt_elora_freeze", "bolt")
tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = 0
tt.render.sprites[1].prefix = "bolt_elora"
tt.bullet.hit_fx = "fx_bolt_elora_hit"
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.mod = "mod_elora_bolt_freeze"
tt.bullet.damage_min = 14
tt.bullet.damage_max = 41
tt.bullet.xp_gain_factor = 2
tt = RT("bolt_elora_slow", "bolt_elora_freeze")
tt.bullet.mod = "mod_elora_bolt_slow"
tt = RT("bolt_magnus", "bolt")
tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = 0
tt.render.sprites[1].prefix = "bolt_magnus"
tt.bullet.hit_fx = "fx_bolt_magnus_hit"
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.acceleration_factor = 0.1
tt.bullet.damage_min = 9
tt.bullet.damage_max = 27
tt.bullet.max_speed = 360
tt.bullet.xp_gain_factor = 2.1
tt = RT("bolt_magnus_illusion", "bolt_magnus")
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.xp_gain_factor = nil
tt = RT("projectile_denas", "arrow")

AC(tt, "sound_events")

tt.bullet.flight_time = fts(20)
tt.bullet.rotation_speed = 15 * FPS * math.pi / 180
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.damage_min = 11
tt.bullet.damage_max = 19
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.miss_decal = nil
tt.bullet.miss_fx = "fx_smoke_bullet"
tt.bullet.track_kills = true
tt.bullet.xp_gain_factor = 2.42
tt.render.sprites[1].name = "hero_king_projectiles_0001"
tt.render.sprites[1].animated = false
tt.sound_events.insert = "AxeSound"
tt = RT("projectile_denas_barrell", "projectile_denas")
tt.render.sprites[1].name = "hero_king_projectiles_0002"
tt = RT("projectile_denas_chicken", "projectile_denas")
tt.render.sprites[1].name = "hero_king_projectiles_0003"
tt = RT("projectile_denas_bottle", "projectile_denas")
tt.render.sprites[1].name = "hero_king_projectiles_0004"
tt = RT("projectile_denas_melee", "projectile_denas")
tt.bullet.flight_time = fts(13)
tt = RT("projectile_denas_melee_barrell", "projectile_denas_barrell")
tt.bullet.flight_time = fts(13)
tt = RT("projectile_denas_melee_chicken", "projectile_denas_chicken")
tt.bullet.flight_time = fts(13)
tt = RT("projectile_denas_melee_bottle", "projectile_denas_bottle")
tt.bullet.flight_time = fts(13)
tt = RT("bomb_musketeer", "bomb")
tt.bullet.damage_max = 0
tt.bullet.damage_max_inc = 90
tt.bullet.damage_min = 0
tt.bullet.damage_min_inc = 50
tt.bullet.damage_radius = 48*1.35
tt.bullet.flight_time_min = fts(4)
tt.bullet.flight_time_max = fts(8)
tt.bullet.hit_fx = "fx_explosion_shrapnel"
tt.bullet.pop = nil
tt.render.sprites[1].name = "bombs_0007"
tt.sound_events.insert = "ShrapnelSound"
tt.sound_events.hit = nil
tt.sound_events.hit_water = nil
tt = RT("bomb_bfg", "bomb")
tt.bullet.damage_max = 165
tt.bullet.damage_min = 80
tt.bullet.damage_radius = 67.5
tt.bullet.flight_time = fts(35)
tt.bullet.hit_fx = "fx_explosion_big"
tt.render.sprites[1].name = "bombs_0005"
tt.sound_events.hit_water = nil
tt = RT("bomb_bfg_cluster", "bullet")

AC(tt, "sound_events")

tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.flight_time = fts(29)
tt.bullet.fragment_count = 1*3
tt.bullet.fragment_name = "bomb_bfg_fragment"
tt.bullet.hide_radius = 2
tt.bullet.hit_fx = "fx_explosion_air"
tt.bullet.rotation_speed = 20 * FPS * math.pi / 180
tt.bullet.fragment_node_spread = 7
tt.bullet.fragment_pos_spread = v(6, 6)
tt.bullet.dest_pos_offset = v(0, 85)
tt.bullet.dest_prediction_time = 1
tt.main_script.insert = scripts.bomb_cluster.insert
tt.main_script.update = scripts.bomb_cluster.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "bombs_0005"
tt.sound_events.hit = "BombExplosionSound"
tt.sound_events.insert = "BombShootSound"
tt = RT("bomb_bfg_fragment", "bomb")
tt.bullet.damage_max = 70*2
tt.bullet.damage_min = 50*2
tt.bullet.damage_radius = 52.5
tt.bullet.flight_time = fts(10)
tt.bullet.hide_radius = 2
tt.bullet.hit_fx = "fx_explosion_fragment"
tt.bullet.pop = nil
tt.render.sprites[1].name = "bombs_0006"
tt.sound_events.hit_water = nil
tt = RT("bomb_goblin_zapper", "bomb")
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_max = 60
tt.bullet.damage_min = 30
tt.bullet.damage_radius = 67.5
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.flight_time = fts(25)
tt.bullet.hit_fx = "fx_explosion_fragment"
tt.bullet.pop = {
	"pop_kboom"
}
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt.render.sprites[1].name = "zapperbomb"
tt.sound_events.insert = nil
tt.sound_events.hit = "BombExplosionSound"
tt = RT("bomb_swamp_thing", "bomb")
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_max = 100
tt.bullet.damage_min = 40
tt.bullet.damage_radius = 47.5
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.flight_time = fts(25)
tt.bullet.hit_fx = "fx_explosion_rotten_shot"
tt.bullet.hit_decal = nil
tt.bullet.pop = nil
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt.render.sprites[1].name = "Proyectile_RottenShot"
tt.sound_events.insert = "swamp_thing_bomb_shot"
tt.sound_events.hit = "swamp_thing_bomb_explosion"
tt = RT("bomb_juggernaut", "bomb")
tt.bullet.damage_bans = F_ALL
tt.bullet.damage_flags = 0
tt.bullet.damage_max = 0
tt.bullet.damage_min = 0
tt.bullet.damage_radius = 1
tt.bullet.flight_time_base = fts(45)
tt.bullet.flight_time_factor = fts(0.025)
tt.bullet.pop = nil
tt.bullet.hit_payload = "juggernaut_bomb_spawner"
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt.bullet.hit_fx = nil
tt.render.sprites[1].name = "bossJuggernaut_bomb_"
tt.sound_events.hit = "BombExplosionSound"
tt = RT("bomb_greenmuck", "bomb")
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.damage_max = 160
tt.bullet.damage_min = 80
tt.bullet.damage_radius = 47.25
tt.bullet.flight_time_base = fts(17)
tt.bullet.flight_time_factor = fts(0.07142857142857142)
tt.bullet.hit_fx = "fx_explosion_rotten_shot"
tt.bullet.hit_decal = nil
tt.bullet.pop = nil
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt.render.sprites[1].name = "Proyectile_RottenBoss"
tt.sound_events.hit = "swamp_thing_bomb_explosion"
tt = RT("bomb_tar_bolin", "bomb")
tt.bullet.damage_bans = F_ALL
tt.bullet.damage_flags = 0
tt.bullet.damage_max = 0
tt.bullet.damage_min = 0
tt.bullet.damage_radius = 1
tt.bullet.flight_time_base = fts(34)
tt.bullet.flight_time_factor = fts(0.016666666666666666)
tt.bullet.pop = nil
tt.bullet.hit_payload = "aura_bolin_tar"
tt.main_script.insert = scripts.bomb.insert
tt.main_script.update = scripts.bomb.update
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.bullet.hide_radius = nil
tt.render.sprites[1].name = "hero_artillery_brea_shot"
tt.render.sprites[1].animated = false
tt.sound_events.insert = "HeroRiflemanBrea"
tt.sound_events.hit = nil
tt.sound_events.hit_water = nil
tt = RT("bomb_mine_bolin", "bomb")
tt.bullet.damage_bans = F_ALL
tt.bullet.damage_flags = 0
tt.bullet.damage_max = 0
tt.bullet.damage_min = 0
tt.bullet.damage_radius = 1
tt.bullet.flight_time = fts(24)
tt.bullet.pop = nil
tt.bullet.hit_payload = "decal_bolin_mine"
tt.main_script.insert = scripts.bomb.insert
tt.main_script.update = scripts.bomb.update
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.bullet.hide_radius = nil
tt.render.sprites[1].name = "hero_artillery_mine_proy"
tt.render.sprites[1].animated = false
tt.sound_events.insert = "HeroRiflemanMine"
tt.sound_events.hit = nil
tt.sound_events.hit_water = nil
tt = E:register_t("denas_catapult_rock", "bomb")
tt.bullet.flight_time = fts(45)
tt.bullet.damage_radius = 45
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.g = -0.8 / (fts(1) * fts(1))
tt.bullet.particles_name = "ps_power_fireball"
tt.render.sprites[1].name = "hero_king_catapultProjectile"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = v(0.7, 0.7)
tt.sound_events.insert = nil
tt = RT("missile_bfg", "bullet")
tt.render.sprites[1].prefix = "missile_bfg"
tt.render.sprites[1].loop = true
tt.bullet.damage_type = DAMAGE_EXPLOSION
tt.bullet.min_speed = 300
tt.bullet.max_speed = 450
tt.bullet.turn_speed = 10 * math.pi / 180 * 30
tt.bullet.acceleration_factor = 0.1
tt.bullet.hit_fx = "fx_explosion_air"
tt.bullet.hit_fx_air = "fx_explosion_air"
tt.bullet.damage_min = 60
tt.bullet.damage_max = 100
tt.bullet.damage_radius = 41.25
tt.bullet.vis_flags = F_RANGED
tt.bullet.damage_flags = F_AREA
tt.bullet.particles_name = "ps_missile"
tt.bullet.retarget_range = 1e+99
tt.main_script.insert = scripts.missile.insert
tt.main_script.update = scripts.missile.update
tt.sound_events.insert = "RocketLaunchSound"
tt.sound_events.hit = "BombExplosionSound"
tt = RT("missile_juggernaut", "bullet")
tt.bullet.acceleration_factor = 0.1
tt.bullet.damage_bans = bor(F_ENEMY, F_BOSS)
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_max = 250
tt.bullet.damage_min = 150
tt.bullet.damage_radius = 41.25
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.hit_fx = "fx_explosion_air"
tt.bullet.hit_fx_air = "fx_explosion_air"
tt.bullet.max_speed = 450
tt.bullet.min_speed = 300
tt.bullet.particles_name = "ps_missile"
tt.bullet.retarget_range = 99999
tt.bullet.rot_dir_from_long_angle = true
tt.bullet.turn_speed = 10 * math.pi / 180 * 30
tt.bullet.vis_bans = bor(F_ENEMY)
tt.bullet.vis_flags = F_RANGED
tt.main_script.update = scripts.enemy_missile.update
tt.render.sprites[1].prefix = "missile_bfg"
tt.render.sprites[1].name = "flying"
tt.sound_events.insert = "RocketLaunchSound"
tt.sound_events.hit = "BombExplosionSound"
tt = RT("ray_arcane", "bullet")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.mod = "mod_ray_arcane"
tt.bullet.hit_time = 0
tt.image_width = 150
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].name = "ray_arcane"
tt.render.sprites[1].loop = true
tt.sound_events.insert = "ArcaneRaySound"
tt.track_target = true
tt.ray_duration = fts(10)
tt = RT("ray_arcane_disintegrate", "ray_arcane")
tt.bullet.mod = "mod_ray_arcane_disintegrate"
tt.image_width = 166
tt.render.sprites[1].name = "ray_arcane_disintegrate"
tt.render.sprites[1].loop = false
tt.sound_events.insert = "DesintegrateSound"
tt = RT("ray_sorcerer_polymorph", "bullet")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_time = fts(3)
tt.bullet.mod = "mod_polymorph_sorcerer"
tt.image_width = 130
tt.main_script.update = scripts.ray_simple.update
tt.ray_duration = fts(10)
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "ray_sorcerer_polymorph"
tt.sound_events.insert = "PolymorphSound"
tt.track_target = true
tt = RT("ray_tesla", "bullet")
tt.bullet.hit_time = fts(1)
tt.bullet.mod = "mod_ray_tesla"
tt.bounces = nil
tt.bounces_lvl = {
	[0] = 2,
	3,
	4
}
tt.bounce_range = 95
tt.bounce_vis_flags = F_RANGED
tt.bounce_vis_bans = 0
tt.bounce_damage_min = 90
tt.bounce_damage_max = 180
tt.bounce_damage_factor = 0.5
tt.bounce_damage_factor_min = 0.5
tt.bounce_damage_factor_inc = 0
tt.bounce_delay = fts(2)
tt.bounce_scale_y = 1
tt.bounce_scale_y_factor = 0.88
tt.excluded_templates = {
	"enemy_spectral_knight"
}
tt.image_width = 106
tt.seen_targets = {}
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].name = "ray_tesla"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_BULLETS
tt.main_script.update = scripts.ray_tesla.update
tt = RT("ray_sunray", "bullet")
tt.bullet.damage_type = bor(DAMAGE_DISINTEGRATE, DAMAGE_TRUE)
tt.bullet.hit_time = fts(1)
tt.bullet.mod = "mod_ray_sunray_hit"
tt.bullet.damage_max = 75
tt.bullet.damage_min = 25
tt.bullet.damage_inc = 50
tt.image_width = 82
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].name = "ray_sunray"
tt.render.sprites[1].loop = false
tt.sound_events.insert = "PolymorphSound"
tt.track_target = true
tt.ray_duration = fts(9)
tt.ray_y_scales = {
	0.4,
	0.6,
	0.8,
	1
}
tt = RT("ray_hero_thor", "ray_tesla")
tt.bullet.mod = "mod_ray_hero_thor"
tt.render.sprites[1].name = "ray_hero_thor"
tt.main_script.update = scripts.ray_thor.update
tt = RT("shotgun_musketeer", "shotgun")
tt.bullet.damage_max = 125
tt.bullet.damage_min = 85
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.miss_fx = "fx_smoke_bullet"
tt.bullet.start_fx = "fx_rifle_smoke"
tt.bullet.min_speed = 20 * FPS
tt.bullet.max_speed = 20 * FPS
tt.sound_events.insert = "ShotgunSound"
tt = RT("shotgun_musketeer_sniper", "shotgun_musketeer")
tt.bullet.particles_name = "ps_shotgun_musketeer"
tt.sound_events.insert = "SniperSound"
tt.bullet.damage_type = bor(DAMAGE_PHYSICAL, DAMAGE_FX_EXPLODE)
tt.bullet.pop = nil
tt.bullet.ignore_upgrades = true
tt = RT("shotgun_musketeer_sniper_instakill", "shotgun_musketeer_sniper")
tt.bullet.damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_FX_EXPLODE)
tt.bullet.pop = {
	"pop_headshot"
}
tt = RT("shotgun_bolin", "shotgun")
tt.bullet.damage_max = 65
tt.bullet.damage_min = 35
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.miss_fx = "fx_smoke_bullet"
tt.bullet.start_fx = nil
tt.bullet.min_speed = 20 * FPS
tt.bullet.max_speed = 20 * FPS
tt.bullet.xp_gain_factor = 3
tt.sound_events.insert = "ShotgunSound"
tt = E:register_t("enemy_spider_egg", "decal_scripted")

E:add_comps(tt, "render", "spawner", "tween")

tt.main_script.update = scripts.enemies_spawner.update
tt.render.sprites[1].anchor.y = 0.22
tt.render.sprites[1].prefix = "enemy_spider_egg"
tt.render.sprites[1].loop = false
tt.spawner.count = 3
tt.spawner.cycle_time = fts(6)
tt.spawner.entity = "enemy_spider_tiny"
tt.spawner.node_offset = 5
tt.spawner.pos_offset = v(0, 1)
tt.spawner.allowed_subpaths = {
	1,
	2,
	3
}
tt.spawner.random_subpath = false
tt.spawner.animation_start = "start"
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		4,
		0
	}
}
tt.tween.remove = true
tt = E:register_t("enemy_spider_rotten_egg", "decal_scripted")

E:add_comps(tt, "render", "spawner", "tween")

tt.main_script.update = scripts.enemies_spawner.update
tt.render.sprites[1].anchor.y = 0.22
tt.render.sprites[1].prefix = "enemy_spider_rotten_egg"
tt.render.sprites[1].loop = false
tt.spawner.count = 3
tt.spawner.cycle_time = fts(6)
tt.spawner.entity = "enemy_spider_rotten_tiny"
tt.spawner.node_offset = 5
tt.spawner.pos_offset = v(0, 1)
tt.spawner.allowed_subpaths = {
	1,
	2,
	3
}
tt.spawner.random_subpath = false
tt.spawner.animation_start = "start"
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		4,
		0
	}
}
tt.tween.remove = true
tt = RT("juggernaut_bomb_spawner", "decal_scripted")

E:add_comps(tt, "render", "spawner", "tween")

tt.main_script.update = scripts.enemies_spawner.update
tt.render.sprites[1].anchor.y = 0.22
tt.render.sprites[1].prefix = "bomb_juggernaut_spawner"
tt.render.sprites[1].loop = false
tt.spawner.animation_concurrent = "open"
tt.spawner.count = 7
tt.spawner.cycle_time = fts(6)
tt.spawner.entity = "enemy_golem_head"
tt.spawner.keep_gold = true
tt.spawner.node_offset = 2
tt.spawner.pos_offset = v(0, 0)
tt.spawner.allowed_subpaths = {
	1,
	2,
	3
}
tt.spawner.random_subpath = false
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		4,
		0
	}
}
tt.tween.remove = true
tt = E:register_t("myconid_spawner")

E:add_comps(tt, "pos", "spawner", "main_script")

tt.main_script.update = scripts.enemies_spawner.update
tt.spawner.count = 2
tt.spawner.random_cycle = {
	0,
	1
}
tt.spawner.entity = "enemy_rotten_lesser"
tt.spawner.random_node_offset_range = {
	-2,
	9
}
tt.spawner.random_subpath = true
tt.spawner.initial_spawn_animation = "raise"
tt.spawner.spawn_sound = "EnemyMushroomBorn"
tt.spawner.spawn_sound_args = {
	delay = fts(29)
}
tt.spawner.check_node_valid = true
tt.spawner.use_node_pos = true
tt = RT("elora_ice_spike", "bullet")
tt.main_script.update = scripts.elora_ice_spike.update
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_radius = 51.2
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_bans = F_FRIEND
tt.bullet.mod = nil
tt.bullet.hit_time = 0.1
tt.bullet.duration = 2
tt.spike_1_anchor_y = 0.16
tt.render.sprites[1].prefix = "elora_ice_spike_"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].anchor.y = 0.2
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].anchor.y = 0.2
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_frost_spikes_decal"
tt.render.sprites[2].z = Z_DECALS
tt.sound_events.delayed_insert = "HeroFrostIceRainDrop"
tt.sound_events.ice_break = "HeroFrostIceRainBreak"
tt = RT("decal_bolin_mine", "decal_scripted")
tt.check_interval = fts(3)
tt.damage_max = nil
tt.damage_min = nil
tt.damage_type = DAMAGE_EXPLOSION
tt.duration = 50
tt.hit_decal = "decal_bomb_crater"
tt.hit_fx = "fx_explosion_fragment"
tt.main_script.update = scripts.decal_bolin_mine.update
tt.radius = 13
tt.render.sprites[1].loop = true
tt.render.sprites[1].name = "decal_bolin_mine"
tt.render.sprites[1].z = Z_DECALS
tt.sound = "BombExplosionSound"
tt.vis_bans = bor(F_FRIEND, F_FLYING)
tt.vis_flags = bor(F_ENEMY)
tt = E:register_t("hacksaw_sawblade", "bullet")
tt.main_script.update = scripts.hacksaw_sawblade.update
tt.bullet.particles_name = "ps_hacksaw_sawblade"
tt.bullet.acceleration_factor = 0.05
tt.bullet.min_speed = 390
tt.bullet.max_speed = 390
tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = 0
tt.bullet.damage_min = 45
tt.bullet.damage_max = 45
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.hit_fx = "fx_hacksaw_sawblade_hit"
tt.bullet.max_speed = 390
tt.bullet.damage_type = DAMAGE_TRUE
tt.bounces_max = nil
tt.bounce_range = 150
tt.render.sprites[1].prefix = "hacksaw_sawblade"
tt.sound_events.insert = "HeroAlienDiscoThrow"
tt.sound_events.bounce = "HeroAlienDiscoBounce"
tt = RT("aura_ranger_thorn", "aura")
tt.aura.mod = "mod_thorn"
tt.aura.duration = -1
tt.aura.radius = 200*1.45
tt.aura.vis_flags = bor(F_THORN, F_MOD)
tt.aura.vis_bans = bor(F_FLYING, F_BOSS)
tt.aura.cooldown = 8 + fts(34)
tt.aura.max_times = 5
tt.aura.max_count = 8
tt.aura.max_count_inc = 3
tt.aura.min_count = 2
tt.aura.owner_animation = "shoot"
tt.aura.owner_sid = 5
tt.aura.hit_time = fts(17)
tt.aura.hit_sound = "ThornSound"
tt.main_script.update = scripts.aura_ranger_thorn.update
tt = RT("aura_teleport_arcane", "aura")

AC(tt, "render")

tt.aura.mod = "mod_teleport_arcane"
tt.aura.duration = fts(23)
tt.aura.apply_delay = fts(5)
tt.aura.apply_duration = fts(10)
tt.aura.max_count = 4
tt.aura.cycle_time = fts(2)
tt.aura.radius = 32.5
tt.aura.vis_flags = bor(F_RANGED, F_MOD, F_TELEPORT)
tt.aura.vis_bans = bor(F_BOSS, F_FRIEND, F_HERO, F_FREEZE)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].name = "aura_teleport_arcane"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].anchor.y = 0.375
tt.sound_events.insert = "TeleporthSound"
tt = RT("aura_tesla_overcharge", "aura")
tt.aura.duration = fts(22)
tt.aura.mod = "mod_tesla_overcharge"
tt.aura.radius = 165*1.5
tt.aura.damage_min = 0
tt.aura.damage_max = 120
tt.aura.damage_inc = 60
tt.aura.damage_type = DAMAGE_ELECTRICAL
tt.aura.excluded_templates = {
	"enemy_spectral_knight"
}
tt.main_script.update = scripts.aura_tesla_overcharge.update
tt.particles_name = "ps_tesla_overcharge"
tt = RT("aura_malik_fissure", "aura")
tt.aura.fx = "decal_malik_earthquake"
tt.aura.damage_radius = 40*2
tt.aura.damage_types = {
	DAMAGE_TRUE,
	DAMAGE_PHYSICAL
}
tt.aura.vis_flags = bor(F_RANGED)
tt.aura.spread_delay = fts(4)
tt.aura.spread_nodes = 4
tt.main_script.update = scripts.aura_malik_fissure.update
tt.stun = {
	vis_flags = bor(F_RANGED, F_STUN),
	vis_bans = bor(F_FLYING, F_BOSS),
	mod = "mod_malik_stun"
}
tt = RT("aura_chill_elora", "aura")

AC(tt, "render", "tween")

tt.aura.cycle_time = fts(10)
tt.aura.duration = 3
tt.aura.mod = "mod_elora_chill"
tt.aura.radius = 44.800000000000004
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_ENEMY)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_chill_elora.update
tt.render.sprites[1].prefix = "decal_elora_chill_"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		0.2,
		0
	}
}
tt = RT("aura_bolin_tar", "aura")

AC(tt, "render", "tween")

tt.aura.cycle_time = fts(10)
tt.aura.duration = 4
tt.aura.mod = "mod_bolin_slow"
tt.aura.radius = 47.5
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_ENEMY)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_slow_bolin.update
tt.render.sprites[1].prefix = "decal_bolin_tar"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		0.3,
		0
	}
}
tt = RT("denas_buff_aura", "aura")

AC(tt, "main_script", "render", "tween")

tt.aura.duration = 1.63
tt.entity = "denas_buffing_circle"
tt.main_script.update = scripts.denas_buff_aura.update
tt.render.sprites[1].name = "hero_king_glowShadow"
tt.render.sprites[1].anchor = v(0.5, 0.26)
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = true
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.13,
		255
	},
	{
		1.63,
		255
	},
	{
		2.76,
		0
	}
}
tt.tween.remove = true
tt = RT("aura_ignus_idle", "aura")
tt.aura.duration = 0
tt.particles_name = "ps_hero_ignus_idle"
tt.emit_states = {
	"idle",
	"attack"
}
tt.main_script.update = scripts.aura_ignus_particles.update
tt.particle_offsets = {
	v(-17, 16),
	v(-12, 27),
	v(4, 37),
	v(2, 35),
	v(12, 22),
	v(14, 13)
}
tt.flip_offset = v(3, 0)
tt = RT("aura_ignus_surge_of_flame", "aura")
tt.aura.cycle_time = fts(1)
tt.aura.duration = 0
tt.aura.damage_min = nil
tt.aura.damage_max = nil
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.damage_radius = 25
tt.aura.hit_fx = "fx_ignus_burn"
tt.damage_state = "surgeOfFlame"
tt.main_script.update = scripts.aura_ignus_surge_of_flame.update
tt.particles_name = "ps_hero_ignus_smoke"
tt = RT("aura_ingvar_bear_regenerate", "aura")

AC(tt, "regen")

tt.aura.duration = 0
tt.main_script.update = scripts.aura_ingvar_bear_regenerate.update
tt.regen.cooldown = 1
tt.regen.health = 2
tt = E:register_t("aura_troll_regen", "aura")

AC(tt, "regen")

tt.main_script.update = scripts.aura_unit_regen.update
tt.regen.cooldown = fts(6)
tt.regen.health = 1
tt.regen.ignore_stun = true
tt.regen.ignore_freeze = false
tt = E:register_t("aura_forest_troll_regen", "aura_troll_regen")

AC(tt, "regen")

tt.main_script.update = scripts.aura_unit_regen.update
tt.regen.cooldown = fts(4)
tt.regen.health = 4
tt = E:register_t("aura_troll_axe_thrower_regen", "aura_troll_regen")

AC(tt, "regen")

tt.main_script.update = scripts.aura_unit_regen.update
tt.regen.cooldown = fts(6)
tt.regen.health = 2
tt = E:register_t("aura_troll_brute_regen", "aura_forest_troll_regen")
tt = E:register_t("aura_troll_chieftain_regen", "aura_troll_regen")
tt.regen.cooldown = fts(6)
tt.regen.health = 4
tt = E:register_t("aura_goblin_zapper_death", "aura")
tt.aura.cycles = 1
tt.aura.damage_min = 50
tt.aura.damage_max = 150
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.radius = 60
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.vis_flags = bor(F_RANGED)
tt.main_script.update = scripts.aura_apply_damage.update
tt = E:register_t("aura_demon_death", "aura")
tt.aura.cycles = 1
tt.aura.damage_min = 50
tt.aura.damage_max = 100
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.excluded_templates = {
	"hero_oni"
}
tt.aura.radius = 60
tt.aura.track_damage = true
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.vis_flags = bor(F_RANGED)
tt.main_script.update = scripts.aura_apply_damage.update
tt = E:register_t("aura_demon_mage_death", "aura_demon_death")
tt.aura.damage_min = 200
tt.aura.damage_max = 400
tt = E:register_t("aura_demon_wolf_death", "aura_demon_death")
tt.aura.damage_min = 70
tt.aura.damage_max = 140
tt = E:register_t("aura_rotten_lesser_death", "aura")
tt.aura.cycles = 1
tt.aura.radius = 60
tt.aura.mod = "mod_rotten_lesser_pestilence"
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.vis_flags = bor(F_MOD, F_POISON)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt = E:register_t("aura_swamp_thing_regen", "aura")

AC(tt, "regen")

tt.main_script.update = scripts.aura_unit_regen.update
tt.regen.cooldown = fts(2)
tt.regen.health = 1
tt.regen.ignore_stun = false
tt.regen.ignore_freeze = false
tt = E:register_t("aura_flareon_death", "aura_demon_death")
tt.aura.damage_min = 40
tt.aura.damage_max = 80
tt = E:register_t("aura_gulaemon_death", "aura_demon_death")
tt.aura.damage_min = 200
tt.aura.damage_max = 400
tt = E:register_t("aura_burning_floor", "aura")

E:add_comps(tt, "render", "tween")

tt.aura.active = false
tt.aura.cycle_time = 0.3
tt.aura.mod = "mod_burning_floor_burn"
tt.aura.radius = 75
tt.aura.vis_flags = bor(F_MOD, F_BURN, F_RANGED)
tt.aura.vis_bans = bor(F_ENEMY)
tt.main_script.update = scripts.aura_burning_floor.update
tt.render.sprites[1].name = "InfernoDecal_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "InfernoDecal_0002"
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -10
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {
	{
		fts(0),
		0
	},
	{
		fts(30),
		255
	}
}
tt.tween.props[1].loop = false
tt.tween.props[1].sprite_id = 2
tt = E:register_t("burning_floor_controller")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.burning_floor_controller.update
tt = E:register_t("aura_demon_cerberus_death", "aura_demon_death")
tt.aura.damage_min = 666
tt.aura.damage_max = 666
tt.aura.radius = 120
tt = RT("aura_spectral_knight", "aura")

AC(tt, "render", "tween")

tt.aura.active = false
tt.aura.allowed_templates = {
	"enemy_fallen_knight"
}
tt.aura.cooldown = 0
tt.aura.delay = fts(30)
tt.aura.duration = -1
tt.aura.mod = "mod_spectral_knight"
tt.aura.radius = 106.38297872340426
tt.aura.track_source = true
tt.aura.use_mod_offset = false
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_spectral_knight.update
tt.render.sprites[1].alpha = 0
tt.render.sprites[1].anchor = v(0.5, 0.28125)
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "CB_DeathKnight_aura_0001"
tt.render.sprites[1].offset = v(0, -16)
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].alpha = 0
tt.render.sprites[2].animated = true
tt.render.sprites[2].name = "spectral_knight_aura"
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(20),
		255
	}
}
tt.tween.props[1].name = "alpha"
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.remove = false
tt = E:register_t("aura_troll_skater_regen", "aura_troll_regen")

AC(tt, "regen")

tt.regen.cooldown = fts(4)
tt.regen.health = 1
tt = RT("graveyard_controller")

AC(tt, "graveyard", "main_script")

tt.main_script.update = scripts.graveyard_controller.update
tt.graveyard.dead_time = 0.5
tt.graveyard.check_interval = 0.25
tt.graveyard.keep_gold = true
tt.graveyard.spawn_interval = 0.1
tt.graveyard.spawns_by_health = {
	{
		"enemy_skeleton",
		299
	},
	{
		"enemy_skeleton_big",
		9e+99
	}
}
tt.graveyard.vis_has = F_ENEMY
tt.graveyard.vis_flags = F_SKELETON
tt.graveyard.vis_bans = F_BOSS
tt = RT("swamp_controller", "graveyard_controller")
tt.graveyard.spawns_by_health = {
	{
		"enemy_zombie",
		400
	},
	{
		"enemy_swamp_thing",
		9e+99
	}
}
tt.graveyard.excluded_templates = {
	"soldier_alleria_wildcat",
	"soldier_magnus_illusion"
}
tt.graveyard.keep_gold = false
tt.graveyard.vis_has = F_FRIEND
tt.graveyard.vis_flags = 0
tt.graveyard.vis_bans = F_HERO
tt = RT("s15_rotten_spawner")

AC(tt, "main_script", "editor")

tt.main_script.update = scripts.s15_rotten_spawner.update
tt.entity = "enemy_rotten_tree"
tt.spawn_margin = {
	30,
	60
}
tt.spawn_timers = {
	{
		10,
		0
	},
	[11] = {
		15,
		1
	},
	[14] = {
		10,
		0
	},
	[15] = {
		15,
		2
	},
	[17] = {
		15,
		3
	},
	[20] = {
		15,
		6
	}
}
tt = RT("s11_lava_spawner")

AC(tt, "main_script")

tt.main_script.update = scripts.s11_lava_spawner.update
tt.entity = "enemy_lava_elemental"
tt.cooldown = 400
tt.cooldown_after = 120
tt.pi = 4
tt.sound = "RockElementalDeath"
tt = RT("jt_spawner_aura", "aura")
tt.main_script.update = scripts.jt_spawner_aura.update
tt.aura.track_source = true
tt.spawn_data = {
	{
		"enemy_whitewolf",
		8,
		0,
		2,
		1
	},
	{
		"enemy_whitewolf",
		8,
		fts(20),
		2,
		2
	},
	{
		"enemy_yeti",
		19,
		0,
		3,
		1
	}
}
tt = E:register_t("blackburn_aura", "aura")
tt.main_script.update = scripts.blackburn_aura.update
tt.aura.cycle_time = 0.5
tt.aura.duration = -1
tt.aura.radius = 106.38297872340426
tt.aura.raise_entity = "enemy_skeleton_big"
tt.count_group_name = "blackburn_skeletons"
tt.count_group_type = COUNT_GROUP_CONCURRENT
tt.count_group_max = 15
tt = RT("veznan_souls_aura", "aura")
tt.main_script.update = scripts.veznan_souls_aura.update
tt.aura.track_source = true
tt.souls = {
	angles = {
		d2r(30),
		d2r(130)
	},
	count = 60,
	delay_frames = 10,
	entity = "veznan_soul"
}
tt = RT("kingpin_damage_aura", "aura")
tt.main_script.update = scripts.aura_apply_damage.update
tt.aura.duration = -1
tt.aura.cycle_time = fts(2)
tt.aura.damage_min = 100
tt.aura.damage_max = 100
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.radius = 65
tt.aura.track_source = true
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.vis_flags = bor(F_RANGED)
tt = RT("aura_elder_shaman_healing", "aura")

AC(tt, "render", "tween")

tt.aura.mod = "mod_elder_shaman_heal"
tt.aura.mod_args = nil
tt.aura.cycle_time = 0.5
tt.aura.duration = nil
tt.aura.radius = nil
tt.aura.vis_bans = bor(F_BOSS, F_FRIEND)
tt.aura.vis_flags = F_MOD
tt.render.sprites[1].alpha = 50
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "totem_groundeffect-orange_0002"
tt.render.sprites[1].scale = v(0.64, 0.64)
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "totem_groundeffect-orange_0001"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].anchor = v(0.5, 0.12264150943396226)
tt.render.sprites[3].loop = false
tt.render.sprites[3].name = "start"
tt.render.sprites[3].prefix = "elder_shaman_totem_orange"
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].anchor = v(0.5, 0.12264150943396226)
tt.render.sprites[4].hidden = true
tt.render.sprites[4].loop = true
tt.render.sprites[4].name = "elder_shaman_totem_orange_fx"
tt.main_script.update = scripts.aura_elder_shaman.update
tt.sound_events.insert = "EndlessOrcsTotemHealing"
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {
	{
		0,
		v(0.64, 0.64)
	},
	{
		fts(15),
		v(1, 1)
	},
	{
		fts(30),
		v(1.6, 1.6)
	}
}
tt.tween.props[1].loop = true
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {
	{
		0,
		50
	},
	{
		fts(10),
		255
	},
	{
		fts(20),
		255
	},
	{
		fts(30),
		0
	}
}
tt.tween.props[2].loop = true
tt = RT("aura_elder_shaman_damage", "aura_elder_shaman_healing")
tt.aura.mod = "mod_elder_shaman_damage"
tt.aura.cycle_time = 0.2
tt.aura.vis_bans = bor(F_BOSS, F_ENEMY)
tt.render.sprites[1].name = "totem_groundeffect-red_0002"
tt.render.sprites[2].name = "totem_groundeffect-red_0001"
tt.render.sprites[3].prefix = "elder_shaman_totem_red"
tt.render.sprites[4].name = "elder_shaman_totem_red_fx"
tt.sound_events.insert = "EndlessOrcsTotemDamage"
tt = RT("aura_elder_shaman_speed", "aura_elder_shaman_healing")
tt.aura.mod = "mod_elder_shaman_speed"
tt.aura.cycle_time = 0.2
tt.render.sprites[1].name = "totem_groundeffect-ligthBlue_0002"
tt.render.sprites[2].name = "totem_groundeffect-lightBlue_0001"
tt.render.sprites[3].prefix = "elder_shaman_totem_blue"
tt.render.sprites[4].name = "elder_shaman_totem_blue_fx"
tt.sound_events.insert = "EndlessOrcsTotemSpeed"
tt = RT("mod_arcane_shatter", "mod_damage")
tt.damage_min = 0.03
tt.damage_max = 0.03
tt.damage_type = bor(DAMAGE_ARMOR, DAMAGE_NO_SHIELD_HIT)
tt = RT("mod_slow_curse", "mod_slow")
tt.main_script.insert = scripts.mod_slow_curse.insert
tt.modifier.excluded_templates = {
	"enemy_demon_cerberus"
}
tt = RT("mod_ranger_poison", "mod_poison")
tt.modifier.duration = 3
tt.dps.damage_max = 0
tt.dps.damage_min = 0
tt.dps.damage_inc = 25
tt.dps.damage_every = 0.6
tt.dps.kill = true
tt.dps.damage_type = bor(DAMAGE_POISON, DAMAGE_NO_SHIELD_HIT)
tt = RT("mod_thorn", "modifier")

AC(tt, "render")

tt.animation_start = "thorn"
tt.animation_end = "thornFree"
tt.modifier.duration = 0
tt.modifier.duration_inc = 1
tt.modifier.type = MOD_TYPE_FREEZE
tt.modifier.vis_flags = bor(F_THORN, F_MOD)
tt.modifier.vis_bans = bor(F_FLYING, F_BOSS)
tt.max_times_applied = 3
tt.damage_min = 40
tt.damage_max = 40
tt.damage_type = DAMAGE_PHYSICAL
tt.damage_every = 1
tt.render.sprites[1].prefix = "mod_thorn_small"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].size_prefixes = {
	"mod_thorn_small",
	"mod_thorn_big",
	"mod_thorn_big"
}
tt.render.sprites[1].size_scales = {
	vv(0.7),
	vv(0.8),
	vv(1)
}
tt.render.sprites[1].anchor.y = 0.22
tt.main_script.queue = scripts.mod_thorn.queue
tt.main_script.dequeue = scripts.mod_thorn.dequeue
tt.main_script.insert = scripts.mod_thorn.insert
tt.main_script.update = scripts.mod_thorn.update
tt.main_script.remove = scripts.mod_thorn.remove
tt = RT("mod_ray_arcane", "modifier")

AC(tt, "render", "dps")

tt.dps.damage_min = 76
tt.dps.damage_max = 140
tt.dps.damage_type = bor(DAMAGE_MAGICAL, DAMAGE_ONE_SHIELD_HIT)
tt.dps.damage_every = fts(2)
tt.dps.pop = {
	"pop_zap_arcane"
}
tt.dps.pop_conds = DR_KILL
tt.main_script.update = scripts.mod_ray_arcane.update
tt.modifier.duration = fts(10)
tt.modifier.allows_duplicates = true
tt.render.sprites[1].name = "mod_ray_arcane"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_BULLETS
tt = RT("mod_ray_arcane_disintegrate", "modifier")

AC(tt, "render")

tt.main_script.update = scripts.mod_ray_arcane_disintegrate.update
tt.modifier.pop = {
	"pop_zap_arcane"
}
tt.modifier.pop_conds = DR_KILL
tt.modifier.damage_type = bor(DAMAGE_DISINTEGRATE, DAMAGE_INSTAKILL, DAMAGE_NO_SPAWNS)
tt.modifier.damage = 1
tt.modifier.duration = fts(10)
tt.render.sprites[1].name = "mod_ray_arcane"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_BULLETS
tt = RT("mod_teleport_arcane", "mod_teleport")
tt.delay_end = fts(6)
tt.delay_start = fts(1)
tt.fx_end = "fx_teleport_arcane"
tt.fx_start = "fx_teleport_arcane"
tt.max_times_applied = 3
tt.modifier.use_mod_offset = true
tt.modifier.vis_bans = bor(F_BOSS, F_FREEZE)
tt.modifier.vis_flags = bor(F_MOD, F_TELEPORT)
tt.nodes_offset_min = -26
tt.nodes_offset_max = -17
tt.nodes_offset_inc = -5
tt = RT("mod_sorcerer_curse_armor", "modifier")

AC(tt, "armor_buff")

tt.modifier.duration = 5
tt.modifier.vis_flags = F_MOD
tt.armor_buff.magic = false
tt.armor_buff.factor = -0.5
tt.armor_buff.cycle_time = 1e+99
tt.main_script.insert = scripts.mod_armor_buff.insert
tt.main_script.remove = scripts.mod_armor_buff.remove
tt.main_script.update = scripts.mod_armor_buff.update
tt = RT("mod_sorcerer_curse_dps", "modifier")

AC(tt, "render", "dps")

tt.modifier.duration = 4.9
tt.modifier.vis_flags = F_MOD
tt.dps.damage_min = 10
tt.dps.damage_max = 10
tt.dps.damage_every = 1.25
tt.dps.damage_type = DAMAGE_TRUE
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.render.sprites[1].name = "small"
tt.render.sprites[1].prefix = "mod_sorcerer_curse"
tt.render.sprites[1].size_names = {
	"small",
	"medium",
	"large"
}
tt.render.sprites[1].size_scales = {
	vv(1),
	vv(1),
	vv(1.5)
}
tt.render.sprites[1].sort_y_offset = -3
tt = RT("mod_polymorph_sorcerer", "mod_polymorph")
tt.modifier.use_mod_offset = true
tt.modifier.remove_banned = true
tt.modifier.ban_types = {
	MOD_TYPE_FAST
}
tt.polymorph.custom_entity_names.default = "enemy_sheep_ground"
tt.polymorph.custom_entity_names.enemy_demon_imp = "enemy_sheep_fly"
tt.polymorph.custom_entity_names.enemy_gargoyle = "enemy_sheep_fly"
tt.polymorph.custom_entity_names.enemy_rocketeer = "enemy_sheep_fly"
tt.polymorph.custom_entity_names.enemy_witch = "enemy_sheep_fly"
tt.polymorph.hit_fx_sizes = {
	"fx_mod_polymorph_sorcerer_small",
	"fx_mod_polymorph_sorcerer_big",
	"fx_mod_polymorph_sorcerer_big"
}
tt.polymorph.pop = {
	"pop_puff"
}
tt.polymorph.transfer_gold_factor = 1
tt.polymorph.transfer_health_factor = 0.5
tt.polymorph.transfer_lives_cost_factor = 1
tt.polymorph.transfer_speed_factor = 1.5
tt = E:register_t("mod_ray_tesla", "modifier")

E:add_comps(tt, "render", "dps")

tt.modifier.duration = fts(14)
tt.modifier.vis_flags = F_MOD
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_type = bor(DAMAGE_ELECTRICAL, DAMAGE_ONE_SHIELD_HIT)
tt.dps.damage_every = fts(2)
tt.dps.cocos_frames = 14
tt.dps.cocos_cycles = 13
tt.dps.pop = {
	"pop_bzzt"
}
tt.dps.pop_chance = 1
tt.dps.pop_conds = DR_KILL
tt.render.sprites[1].prefix = "mod_tesla_hit"
tt.render.sprites[1].size_names = {
	"small",
	"medium",
	"large"
}
tt.render.sprites[1].z = Z_BULLETS + 1
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt = RT("mod_tesla_overcharge", "modifier")

AC(tt, "render")

tt.modifier.duration = fts(20)
tt.modifier.vis_flags = F_MOD
tt.render.sprites[1].prefix = "mod_tesla_hit"
tt.render.sprites[1].size_names = {
	"small",
	"medium",
	"large"
}
tt.render.sprites[1].z = Z_BULLETS + 1
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update
tt = RT("mod_healing_paladin", "modifier")

AC(tt, "hps")

tt.hps.heal_every = 1e+99
tt.hps.heal_min = 0
tt.hps.heal_max = 0
tt.hps.heal_min_inc = 40
tt.hps.heal_max_inc = 60
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update
tt.modifier.duration = fts(1)
tt.modifier.bans = {
	"mod_poison_giant_rat"
}
tt.modifier.remove_banned = true
tt = RT("mod_ray_sunray_hit", "modifier")

AC(tt, "render")

tt.modifier.duration = fts(22)
tt.render.sprites[1].name = "fx_ray_sunray_hit"
tt.render.sprites[1].z = Z_BULLETS + 1
tt.render.sprites[1].loop = false
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update
tt = RT("mod_gerald_courage", "modifier")

AC(tt, "render")

tt.courage = {
	heal_once_factor = 0.15,
	damage_min_inc = 2,
	damage_max_inc = 2,
	armor_inc = 0.05,
	magic_armor_inc = 0
}
tt.modifier.duration = 6
tt.modifier.use_mod_offset = false
tt.main_script.insert = scripts.mod_gerald_courage.insert
tt.main_script.remove = scripts.mod_gerald_courage.remove
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].name = "mod_gerald_courage"
tt.render.sprites[1].anchor = v(0.51, 0.17307692307692307)
tt.render.sprites[1].draw_order = 2
tt = RT("mod_malik_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_FLYING, F_BOSS)
tt = E:register_t("mod_ray_hero_thor", "mod_ray_tesla")
tt.modifier.duration = fts(16)
tt.dps.damage_every = fts(2)
tt.dps.damage_min = 5
tt.dps.damage_max = 5
tt.dps.damage_type = DAMAGE_MAGICAL
tt = RT("mod_hero_thor_chainlightning", "modifier")
tt.chainlightning = {
	bullet = "ray_hero_thor",
	count = 2,
	damage = 40,
	offset = v(25, -1),
	damage_type = DAMAGE_TRUE,
	chain_delay = fts(2),
	max_range = 110,
	min_range = 40,
	mod = "mod_tesla_overcharge"
}
tt.main_script.update = scripts.mod_hero_thor_chainlightning.update
tt = RT("mod_hero_thor_thunderclap", "modifier")

AC(tt, "render")

tt.thunderclap = {
	damage = 60,
	offset = v(0, 10),
	damage_type = DAMAGE_TRUE,
	explosion_delay = fts(3),
	secondary_damage = 50,
	secondary_damage_type = DAMAGE_MAGICAL,
	radius = 70,
	stun_duration_max = 3,
	stun_duration_min = 2,
	mod_stun = "mod_hero_thor_stun",
	mod_fx = "mod_tesla_overcharge",
	fx = "fx_hero_thor_thunderclap_disipate",
	sound = "HeroThorThunder"
}
tt.main_script.update = scripts.mod_hero_thor_thunderclap.update
tt.main_script.insert = scripts.mod_track_target.insert
tt.render.sprites[1].anchor = v(0.5, 0.15)
tt.render.sprites[1].name = "mod_hero_thor_thunderclap"
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].loop = false
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "mod_hero_thor_thunderclap_explosion"
tt = RT("mod_hero_thor_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_BOSS)
tt = RT("mod_elora_chill", "mod_slow")
tt.modifier.duration = fts(11)
tt.slow.factor = 0.8
tt = RT("mod_elora_bolt_freeze", "mod_freeze")

AC(tt, "render")

tt.modifier.duration = 2
tt.render.sprites[1].prefix = "freeze_creep"
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[1].loop = false
tt.custom_offsets = {
	flying = v(-5, 32)
}
tt.custom_suffixes = {
	flying = "_air"
}
tt.custom_animations = {
	"start",
	"end"
}
tt = RT("mod_elora_bolt_slow", "mod_slow")
tt.modifier.duration = 2
tt.slow.factor = 0.5
tt = RT("mod_bolin_slow", "mod_slow")
tt.modifier.duration = 1
tt.slow.factor = 0.5
tt = RT("mod_denas_tower", "modifier")

AC(tt, "render", "tween")

tt.range_factor = 1.2
tt.cooldown_factor = 0.8
tt.main_script.insert = scripts.mod_denas_tower.insert
tt.main_script.remove = scripts.mod_denas_tower.remove
tt.main_script.update = scripts.mod_denas_tower.update
tt.modifier.duration = nil
tt.modifier.use_mod_offset = false
tt.render.sprites[1].draw_order = 11
tt.render.sprites[1].name = "mod_denas_tower"
tt.render.sprites[1].anchor = v(0.5, 0.32)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].offset.y = 7
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.5,
		255
	}
}
tt.tween.remove = false
tt = E:register_t("mod_shaman_heal", "modifier")

E:add_comps(tt, "hps", "render")

tt.hps.heal_min = 50
tt.hps.heal_max = 50
tt.hps.heal_every = 9e+99
tt.render.sprites[1].prefix = "healing"
tt.render.sprites[1].size_names = {
	"small",
	"medium",
	"large"
}
tt.render.sprites[1].name = "small"
tt.render.sprites[1].loop = false
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update
tt.modifier.duration = fts(24)
tt.modifier.allows_duplicates = true
tt = E:register_t("mod_rocketeer_speed_buff", "modifier")

AC(tt, "fast")

tt.main_script.insert = scripts.mod_rocketeer_speed_buff.insert
tt.main_script.remove = scripts.mod_rocketeer_speed_buff.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = 2
tt.modifier.type = MOD_TYPE_FAST
tt.sound_events.insert = "EnemyRocketeer"
tt.fast.factor = 3.6041666666666665
tt.walk_angles = {
	"walkingRightLeft_fast",
	"walkingUp_fast",
	"walkingDown_fast"
}
tt = RT("mod_troll_rage", "modifier")

AC(tt, "render")

tt.extra_armor = 0.5
tt.extra_damage_max = 30
tt.extra_damage_min = 15
tt.extra_speed = 30.72
tt.main_script.insert = scripts.mod_troll_rage.insert
tt.main_script.remove = scripts.mod_troll_rage.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = 6
tt.modifier.type = MOD_TYPE_RAGE
tt.modifier.vis_flags = bor(F_MOD)
tt.modifier.use_mod_offset = false
tt.render.sprites[1].anchor.y = 0.2
tt.render.sprites[1].name = "mod_troll_rage"
tt = RT("mod_troll_heal", "mod_shaman_heal")
tt = RT("mod_demon_shield", "modifier")

AC(tt, "render")

tt.modifier.bans = {
	"mod_sorcerer_curse_dps",
	"mod_sorcerer_curse_armor"
}
tt.modifier.remove_banned = true
tt.modifier.duration = 1e+99
tt.modifier.vis_flags = bor(F_MOD)
tt.shield_ignore_hits = 4
tt.main_script.insert = scripts.mod_demon_shield.insert
tt.main_script.remove = scripts.mod_demon_shield.remove
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].name = "fx_shield_small"
tt = RT("mod_rotten_lesser_pestilence", "mod_poison")
tt.dps.damage_every = fts(4)
tt.dps.damage_max = 2
tt.dps.damage_min = 2
tt.modifier.duration = 5 - fts(4)
tt.render.sprites[1].prefix = "poison_violet"
tt = RT("mod_poison_giant_rat", "mod_poison")
tt.dps.damage_every = fts(7)
tt.dps.damage_max = 10
tt.dps.damage_min = 10
tt.modifier.duration = 2
tt.reduced_damage_factor = 0.5
tt.render.sprites[1].prefix = "poison_violet"
tt.main_script.insert = scripts.mod_giant_rat_poison.insert
tt.main_script.remove = scripts.mod_giant_rat_poison.remove
tt = RT("mod_wererat_poison", "mod_poison_giant_rat")
tt.dps.damage_max = 15
tt.dps.damage_min = 15
tt = RT("mod_flareon_burn", "mod_lava")
tt.dps.damage_min = 20
tt.dps.damage_max = 20
tt.dps.damage_inc = 0
tt.dps.damage_every = fts(11)
tt.dps.damage_type = DAMAGE_POISON
tt.modifier.duration = 3
tt.modifier.vis_flags = bor(F_MOD, F_BURN)
tt = RT("mod_gulaemon_fly", "modifier")
tt.main_script.queue = scripts.mod_gulaemon_fly.queue
tt.main_script.dequeue = scripts.mod_gulaemon_fly.dequeue
tt.main_script.insert = scripts.mod_gulaemon_fly.insert
tt.main_script.remove = scripts.mod_gulaemon_fly.remove
tt.main_script.update = scripts.mod_gulaemon_fly.update
tt.modifier.duration = 2
tt.modifier.type = MOD_TYPE_FAST
tt.speed_factor = 3.666666666666667
tt.nodes_limit = 20
tt = RT("mod_troll_skater", "modifier")
tt.main_script.queue = scripts.mod_gulaemon_fly.queue
tt.main_script.dequeue = scripts.mod_gulaemon_fly.dequeue
tt.main_script.insert = scripts.mod_gulaemon_fly.insert
tt.main_script.update = scripts.mod_gulaemon_fly.update
tt.modifier.type = MOD_TYPE_FAST
tt.speed_factor = 2.4166666666666665
tt.nodes_limit = 1
tt.modifier.duration = 1000000000
tt = RT("mod_burning_floor_burn", "mod_flareon_burn")
tt.modifier.duration = 0.5
tt = RT("mod_witch_frog", "modifier")

AC(tt, "render", "tween")

tt.animation_delay = 0.8
tt.main_script.insert = scripts.mod_witch_frog.insert
tt.main_script.update = scripts.mod_witch_frog.update
tt.modifier.damage_max = 60
tt.modifier.damage_min = 40
tt.modifier.damage_type = DAMAGE_EAT
tt.modifier.hero_damage_type = DAMAGE_MAGICAL
tt.render.sprites[1].anchor.y = 0.24
tt.render.sprites[1].hidden = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "mod_witch_frog"
tt.frog_delay = fts(4)
tt.fx_delay = fts(19)
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		v(0, 0)
	},
	{
		1.5,
		v(16, 0)
	}
}
tt.tween.props[1].name = "offset"
tt.tween.remove = false
tt = RT("mod_spectral_knight", "modifier")

AC(tt, "render")

tt.damage_factor_increase = 1.2
tt.main_script.insert = scripts.mod_spectral_knight.insert
tt.main_script.remove = scripts.mod_spectral_knight.remove
tt.main_script.update = scripts.mod_track_target.update
tt.max_times_applied = 1
tt.modifier.duration = 6
tt.modifier.use_mod_offset = false
tt.modifier.vis_flags = bor(F_MOD)
tt.render.sprites[1].achor = v(0, 0)
tt.render.sprites[1].name = "mod_spectral_knight_fx"
tt.render.sprites[1].offset = v(0, 32)
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "CB_DeathKnight_buffed"
tt = E:register_t("mod_jt_tower", "modifier")

E:add_comps(tt, "render", "tween", "ui")

tt.main_script.update = scripts.mod_jt_tower.update
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "start"
tt.render.sprites[1].offset.y = 36
tt.render.sprites[1].prefix = "mod_jt"
tt.render.sprites[1].z = Z_OBJECTS

if IS_CONSOLE then
	tt.render.sprites[2] = CC("sprite")
	tt.render.sprites[2].alpha = 150
	tt.render.sprites[2].alpha_focused = 255
	tt.render.sprites[2].alpha_unfocused = 150
	tt.render.sprites[2].animated = false
	tt.render.sprites[2].name = "joystick_shortcuts_hud_0007"
	tt.render.sprites[2].name_focused = "joystick_shortcuts_hud_halo_0007"
	tt.render.sprites[2].name_unfocused = "joystick_shortcuts_hud_0007"
	tt.render.sprites[2].offset.y = 20
	tt.render.sprites[2].scale = vv(1.6)
else
	tt.render.sprites[2] = CC("sprite")
	tt.render.sprites[2].name = "decal_jt_tap"
	tt.render.sprites[2].offset = v(10, 20)
	tt.render.sprites[2].random_ts = fts(7)
end

tt.render.sprites[2].draw_order = 11
tt.render.sprites[2].hidden = true
tt.render.sprites[2].z = Z_OBJECTS
tt.required_clicks = IS_PHONE and 5 or 3
tt.end_delay = fts(5)
tt.sound_events.click = "JtHitIce"
tt.tween.remove = false
tt.tween.props[1].disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		1,
		0
	}
}

if IS_CONSOLE then
	tt.tween.props[2] = CC("tween_prop")
	tt.tween.props[2].name = "scale"
	tt.tween.props[2].keys = {
		{
			0,
			vv(1.6)
		},
		{
			0.25,
			vv(1.9)
		},
		{
			0.5,
			vv(1.6)
		}
	}
	tt.tween.props[2].sprite_id = 2
	tt.tween.props[2].loop = true
end

tt.ui.can_select = false
tt.ui.can_click = true
tt.ui.click_rect = r(-40, 0, 80, 60)
tt.ui.click_fx = "fx_jt_tower_click"
tt.ui.z = 1
tt = E:register_t("mod_gulthak_heal", "mod_shaman_heal")
tt.hps.heal_min = 200
tt.hps.heal_max = 200
tt = E:register_t("mod_kingpin_heal_self", "mod_shaman_heal")
tt.hps.heal_min = 500
tt.hps.heal_max = 500
tt.render.sprites[1].anchor.y = 0.3
tt = E:register_t("mod_kingpin_heal_others", "mod_shaman_heal")
tt.hps.heal_min = 50
tt.hps.heal_max = 50
tt = RT("mod_myconid_poison", "mod_poison")
tt.dps.damage_every = fts(2)
tt.dps.damage_max = 4
tt.dps.damage_min = 4
tt.modifier.duration = 5
tt.render.sprites[1].prefix = "poison_violet"
tt = RT("mod_blackburn_stun", "mod_stun")
tt.modifier.duration = 4
tt.modifier.duration_heroes = 2
tt = RT("mod_blackburn_tower", "modifier")

AC(tt, "render", "tween", "main_script")

tt.main_script.update = scripts.mod_blackburn_tower.update
tt.modifier.duration = 4
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].loop = true
tt.render.sprites[1].offset.y = 36
tt.render.sprites[1].name = "mod_blackburn_tower"
tt.render.sprites[1].z = Z_OBJECTS
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(10),
		255
	}
}
tt = E:register_t("mod_veznan_tower", "modifier")

E:add_comps(tt, "render", "ui")

if IS_CONSOLE then
	E:add_comps(tt, "tween")
end

tt.click_time = 4
tt.duration = 6
tt.main_script.update = scripts.mod_veznan_tower.update
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "start"
tt.render.sprites[1].offset.y = 36
tt.render.sprites[1].prefix = "mod_veznan"
tt.render.sprites[1].z = Z_OBJECTS

if IS_CONSOLE then
	tt.render.sprites[2] = CC("sprite")
	tt.render.sprites[2].alpha = 150
	tt.render.sprites[2].alpha_focused = 255
	tt.render.sprites[2].alpha_unfocused = 150
	tt.render.sprites[2].animated = false
	tt.render.sprites[2].name = "joystick_shortcuts_hud_0007"
	tt.render.sprites[2].name_focused = "joystick_shortcuts_hud_halo_0007"
	tt.render.sprites[2].name_unfocused = "joystick_shortcuts_hud_0007"
	tt.render.sprites[2].offset.y = 20
	tt.render.sprites[2].scale = vv(1.6)
else
	tt.render.sprites[2] = CC("sprite")
	tt.render.sprites[2].name = "decal_veznan_tap"
	tt.render.sprites[2].offset = v(10, 20)
	tt.render.sprites[2].random_ts = fts(7)
end

tt.render.sprites[2].draw_order = 11
tt.render.sprites[2].hidden = true
tt.render.sprites[2].z = Z_OBJECTS
tt.required_clicks = IS_PHONE and 5 or IS_CONSOLE and 1 or 3
tt.sound_blocked = "VeznanHoldTrap"
tt.sound_click = "VeznanHoldHit"
tt.sound_released = "VeznanHoldDissipate"

if IS_CONSOLE then
	tt.tween.remove = false
	tt.tween.props[1] = CC("tween_prop")
	tt.tween.props[1].name = "scale"
	tt.tween.props[1].keys = {
		{
			0,
			vv(1.6)
		},
		{
			0.25,
			vv(1.9)
		},
		{
			0.5,
			vv(1.6)
		}
	}
	tt.tween.props[1].sprite_id = 2
	tt.tween.props[1].loop = true
end

tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect = r(-40, 0, 80, 60)
tt.ui.z = 1
tt = RT("mod_elder_shaman_heal", "mod_shaman_heal")
tt.hps.heal_min = nil
tt.hps.heal_max = nil
tt = RT("mod_elder_shaman_damage", "mod_lava")
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_every = fts(15)
tt.modifier.duration = 1
tt = RT("mod_elder_shaman_speed", "mod_slow")

AC(tt, "render")

tt.slow.factor = nil
tt.modifier.duration = 3
tt.render.sprites[1].name = "mod_elder_shaman_speed"

E:set_template("user_power_1", E:get_template("power_fireball_control"))
E:set_template("user_power_2", E:get_template("power_reinforcements_control"))

tt = RT("decal_sheep_big", "decal_delayed_click_play")

AC(tt, "tween")

tt.delayed_play.achievement_inc = "SHEEP_KILLER"
tt.delayed_play.click_interrupts = true
tt.delayed_play.click_tweens = true
tt.delayed_play.click_sound = "Sheep"
tt.delayed_play.clicked_animation = nil
tt.delayed_play.clicked_sound = "DeathEplosion"
tt.delayed_play.clicked_sound_alt = "BombExplosionSound"
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.play_once = true
tt.delayed_play.required_clicks = 8
tt.delayed_play.required_clicks_fx = "fx_unit_explode"
tt.delayed_play.required_clicks_fx_alt = "fx_explosion_small"
tt.delayed_play.required_clicks_fx_alt_chance = 0.1
tt.delayed_play.required_clicks_hide = true
tt.main_script.insert = scripts.decal_sheep_big.insert
tt.render.sprites[1].anchor.y = 0.1
tt.render.sprites[1].prefix = "decal_sheep_big"
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		v(1, 1)
	},
	{
		0.12,
		v(1.2, 1.2)
	},
	{
		0.16,
		v(1, 1)
	}
}
tt.tween.props[1].name = "scale"
tt.tween.remove = false
tt.ui.click_rect = r(-10, -5, 20, 20)
tt.ui.can_select = false
tt = RT("decal_sheep_small", "decal_sheep_big")
tt.render.sprites[1].prefix = "decal_sheep_small"
tt = RT("decal_mill_big", "decal_click_pause")
tt.render.sprites[1].name = "decal_mill_big"
tt.ui.can_select = false
tt.ui.click_rect = r(-10, -30, 40, 65)
tt = RT("decal_mill_small", "decal_mill_big")
tt.render.sprites[1].name = "decal_mill_small"
tt.ui.click_rect = r(-10, -25, 35, 55)
tt = RT("decal_s01_trees", "decal")
tt.render.sprites[1].name = "stage1_trees"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.234375
tt = RT("decal_boat_big", "decal_loop")
tt.render.sprites[1].name = "decal_boat_big_idle"
tt = RT("decal_boat_small", "decal_loop")
tt.render.sprites[1].name = "decal_boat_small_idle"
tt = RT("decal_fish", "decal_scripted")

AC(tt, "ui")

tt.render.sprites[1].prefix = "decal_fish"
tt.render.sprites[1].name = "jump"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hidden = true
tt.main_script.update = scripts.decal_fish.update
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect = r(-24, -17, 48, 34)
tt.achievement_id = "CATCH_A_FISH"
tt = RT("decal_water_spark", "decal_loop")
tt.render.sprites[1].name = "decal_water_spark_play"
tt = E:register_t("decal_water_wave", "decal_delayed_play")
tt.render.sprites[1].name = "decal_water_wave_play"
tt.delayed_play.min_delay = 1
tt.delayed_play.max_delay = 3
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_water_wave_play"
tt = RT("decal_goat", "decal_sheep_big")
tt.render.sprites[1].prefix = "decal_goat"
tt = RT("decal_tunnel_light", "decal_scripted")

AC(tt, "tween")

tt.main_script.update = scripts.decal_tunnel_light.update
tt.render.sprites[1].name = "cave_light_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].hidden = true
tt.tween.remove = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].loop = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		0.15,
		200
	},
	{
		0.3,
		255
	},
	{
		0.4,
		220
	},
	{
		0.7,
		255
	}
}
tt.track_names = nil
tt.track_ids = nil
tt = RT("decal_burner_big", "decal_loop")
tt.render.sprites[1].anchor = v(0.5, 0.13)
tt.render.sprites[1].name = "decal_burner_big_idle"
tt = RT("decal_burner_small", "decal_loop")
tt.render.sprites[1].anchor = v(0.5, 0.11)
tt.render.sprites[1].name = "decal_burner_small_idle"
tt = E:register_t("decal_fredo", "decal_scripted")

E:add_comps(tt, "ui")

tt.render.sprites[1].prefix = "decal_fredo"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor = v(0.5, 0.1)
tt.render.sprites[1].loop = false
tt.main_script.update = scripts.decal_fredo.update
tt.ui.can_click = true
tt.ui.click_rect = r(-33, 104, 30, 30)
tt = RT("decal_orc_burner", "decal_loop")
tt.render.sprites[1].name = "decal_orc_burner_idle"
tt.render.sprites[1].random_ts = fts(14)
tt = RT("decal_orc_flag", "decal_loop")
tt.render.sprites[1].anchor = v(0.5, 0.07)
tt.render.sprites[1].random_ts = fts(14)
tt.render.sprites[1].name = "decal_orc_flag_idle"
tt = RT("decal_swamp_bubble", "decal_delayed_play")
tt.render.sprites[1].name = "decal_swamp_bubble_jump"
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.min_delay = fts(150)
tt.delayed_play.max_delay = fts(400)
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_swamp_bubble_jump"
tt = E:register_t("decal_demon_portal_big", "decal_scripted")

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "decal_demon_portal_big_active"
tt.main_script.update = scripts.decal_demon_portal_big.update
tt.fx_out = "fx_demon_portal_out"
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -10
tt.tween.props[1].name = "alpha"
tt.tween.props[1].loop = false
tt.tween.props[1].keys = {
	{
		fts(0),
		0
	},
	{
		fts(30),
		180
	},
	{
		fts(40),
		255
	}
}
tt.out_nodes = nil
tt.shutdown_timeout = 5
tt = E:register_t("decal_s17_barricade", "decal")

E:add_comps(tt, "editor", "main_script")

tt.boss_name = "eb_kingpin"
tt.boss_spawn_wave = 15
tt.main_script.update = scripts.decal_s17_barricade.update
tt.render.sprites[1].prefix = "decal_s17_barricade"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.x = 0.4
tt.render.sprites[1].loop = false
tt.editor.props = {
	{
		"editor.game_mode",
		PT_NUMBER
	}
}
tt = RT("decal_bandits_flag", "decal_loop")
tt.render.sprites[1].random_ts = fts(14)
tt.render.sprites[1].name = "decal_bandits_flag_idle"
tt = E:register_t("decal_scrat", "decal_scripted")

E:add_comps(tt, "ui")

tt.render.sprites[1].prefix = "decal_scrat"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "decal_scrat_ice"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].anchor = v(0.5, 0.5)
tt.render.sprites[2].loop = false
tt.touch_fx = "fx_decal_scrat_touch"
tt.main_script.update = scripts.decal_scrat.update
tt.ui.can_click = true
tt.ui.click_rect = r(-45, 5, 40, 40)
tt = RT("fx_decal_scrat_touch", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "decal_scrat_touch_fx"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.sound_events.insert = "JtHitIce"
tt = RT("decal_troll_flag", "decal_loop")
tt.render.sprites[1].random_ts = fts(18)
tt.render.sprites[1].name = "decal_troll_flag_idle"
tt = RT("decal_troll_burner", "decal_loop")
tt.render.sprites[1].random_ts = fts(11)
tt.render.sprites[1].name = "decal_troll_burner_idle"
tt = E:register_t("decal_frozen_mushroom", "decal_click_play")
tt.render.sprites[1].prefix = "decal_frozen_mushroom"
tt.click_play.required_clicks = 1
tt.click_play.clicked_sound = "MushroomPoof"
tt.click_play.play_once = true
tt = RT("decal_lava_fall", "decal_loop")
tt.render.sprites[1].name = "decal_lava_fall_idle"
tt = RT("decal_inferno_bubble", "decal_delayed_play")
tt.render.sprites[1].name = "decal_inferno_bubble_jump"
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.min_delay = fts(150)
tt.delayed_play.max_delay = fts(400)
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_inferno_bubble_jump"
tt = RT("decal_lava_splash", "decal_inferno_bubble")
tt.render.sprites[1].name = "decal_lava_splash_jump"
tt.delayed_play.play_animation = "decal_lava_splash_jump"
tt = E:register_t("decal_inferno_portal", "decal_demon_portal_big")
tt.render.sprites[1].name = "decal_inferno_portal_active"
tt = E:register_t("decal_inferno_ground_portal", "decal_demon_portal_big")
tt.render.sprites[1].name = "decal_inferno_ground_portal_active"
tt = E:register_t("decal_s21_veznan", "decal")
tt.render.sprites[1].name = "Inferno_Stg21_Veznan_0001"
tt.render.sprites[1].animated = false
tt = E:register_t("decal_s21_veznan_free", "decal")
tt.render.sprites[1].name = "Inferno_Stg21_Veznan_0002"
tt.render.sprites[1].animated = false
tt = E:register_t("decal_s21_hellboy", "decal")
tt.render.sprites[1].name = "decal_s21_hellboy_idle"
tt = E:register_t("background_sounds_blackburn", "background_sounds")
tt.min_delay = 20
tt.max_delay = 30
tt.sounds = {}
tt = E:register_t("decal_s23_splinter", "decal_click_play")
tt.render.sprites[1].prefix = "decal_s23_splinter"
tt.render.sprites[1].loop = false
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect.pos.x = -6
tt.ui.click_rect.size.x = 25
tt = E:register_t("decal_s23_splinter_pizza", "decal_s23_splinter")
tt.main_script.update = scripts.decal_s23_splinter_pizza.update
tt.render.sprites[1].prefix = "decal_s23_splinter_pizza"
tt = E:register_t("decal_bat_flying", "decal_delayed_play")

E:add_comps(tt, "tween")

tt.render.sprites[1].prefix = "decal_bat_flying"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].z = Z_BULLETS
tt.main_script.insert = scripts.decal_bat_flying.insert
tt.delayed_play.min_delay = 5
tt.delayed_play.max_delay = 20
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_duration = 2
tt.tween.remove = false
tt.tween.props[1].name = "offset"
local bat_speed_per_node = 0.035
local bat_paths = {
	{
		v(-7.74, 618.5),
		v(-0.64, 619.52),
		v(6.27, 620.86),
		v(13.12, 622.27),
		v(19.97, 623.81),
		v(26.62, 625.54),
		v(33.41, 627.46),
		v(40, 629.57),
		v(46.59, 631.87),
		v(53.12, 634.43),
		v(59.39, 637.06),
		v(65.66, 639.87),
		v(71.74, 643.07),
		v(77.63, 646.34),
		v(83.52, 650.05),
		v(89.15, 653.89),
		v(94.66, 658.11),
		v(99.71, 662.72),
		v(104.7, 667.65),
		v(109.12, 672.9),
		v(113.22, 678.59),
		v(116.86, 684.54),
		v(119.94, 690.82),
		v(122.5, 697.41),
		v(124.42, 704.06),
		v(125.7, 710.91),
		v(126.08, 717.95),
		v(125.25, 724.8),
		v(123.2, 731.58),
		v(120.06, 737.86),
		v(116.1, 743.87),
		v(111.68, 749.7),
		v(107.2, 755.26),
		v(102.72, 760.7),
		v(98.18, 766.21),
		v(94.21, 771.9),
		v(90.56, 777.79),
		v(87.68, 784.19)
	},
	{
		v(502.46, 774.14),
		v(503.42, 767.23),
		v(504.7, 760.38),
		v(506.11, 753.54),
		v(507.84, 746.75),
		v(509.76, 739.97),
		v(511.81, 733.44),
		v(514.18, 727.1),
		v(516.99, 720.96),
		v(520.13, 715.01),
		v(523.97, 709.38),
		v(528.45, 704.38),
		v(534.21, 700.42),
		v(540.8, 698.11),
		v(547.71, 698.11),
		v(554.69, 699.01),
		v(561.47, 700.86),
		v(568, 703.36),
		v(574.27, 706.62),
		v(580.16, 710.46),
		v(585.73, 714.62),
		v(590.98, 718.78),
		v(596.29, 722.69),
		v(602.5, 725.7),
		v(609.54, 726.59),
		v(617.09, 725.82),
		v(624.38, 724.93),
		v(631.36, 724.1),
		v(638.27, 723.65),
		v(645.12, 723.65),
		v(652.03, 724.35),
		v(658.82, 725.7),
		v(665.47, 728.13),
		v(671.94, 731.33),
		v(677.7, 735.23),
		v(683.14, 739.97),
		v(688, 745.15),
		v(692.42, 750.78),
		v(696.26, 756.67),
		v(699.71, 762.88),
		v(702.85, 769.09),
		v(706.24, 776.83)
	},
	{
		v(1031.49, 454.02),
		v(1024.38, 455.17),
		v(1017.54, 456.45),
		v(1010.62, 457.79),
		v(1003.84, 459.39),
		v(997.12, 461.18),
		v(990.46, 462.98),
		v(983.74, 465.15),
		v(977.15, 467.46),
		v(970.62, 469.95),
		v(964.42, 472.64),
		v(958.21, 475.46),
		v(952.13, 478.53),
		v(946.18, 481.86),
		v(940.35, 485.5),
		v(934.72, 489.41),
		v(929.28, 493.7),
		v(924.16, 498.24),
		v(919.3, 503.1),
		v(914.69, 508.48),
		v(910.66, 514.05),
		v(907.01, 520),
		v(903.94, 526.27),
		v(901.31, 532.74),
		v(899.33, 539.52),
		v(898.05, 546.37),
		v(897.73, 553.28),
		v(898.56, 560.26),
		v(900.54, 566.98),
		v(903.55, 573.18),
		v(907.58, 579.2),
		v(912, 585.15),
		v(916.48, 590.72),
		v(920.9, 596.29),
		v(925.44, 601.6),
		v(929.41, 607.3),
		v(933.06, 613.18),
		v(936.38, 619.26),
		v(939.52, 625.6),
		v(941.95, 632.06),
		v(944, 638.72),
		v(945.6, 645.57),
		v(946.69, 652.61),
		v(947.46, 659.78),
		v(947.84, 666.75),
		v(947.9, 673.79),
		v(947.65, 680.83),
		v(947.14, 687.87),
		v(946.3, 694.85),
		v(945.22, 701.89),
		v(942.78, 708.61),
		v(939.71, 715.26),
		v(936.32, 721.47),
		v(932.86, 727.42),
		v(929.02, 733.44),
		v(925.06, 739.14),
		v(920.83, 744.77),
		v(916.54, 750.21),
		v(912, 755.58),
		v(907.26, 760.7),
		v(902.34, 765.82),
		v(897.41, 770.82),
		v(892.29, 775.42),
		v(887.17, 780.22)
	},
	{
		v(1028.54, 116.61),
		v(1022.78, 120.96),
		v(1016.9, 124.99),
		v(1010.82, 128.83),
		v(1004.74, 132.22),
		v(998.46, 135.3),
		v(992, 138.18),
		v(985.41, 140.61),
		v(978.75, 142.66),
		v(971.78, 144.19),
		v(964.86, 145.6),
		v(957.76, 146.37),
		v(950.66, 146.69),
		v(943.62, 146.56),
		v(936.77, 145.41),
		v(930.05, 142.98),
		v(924.1, 139.07),
		v(918.85, 134.27),
		v(914.37, 128.58),
		v(910.72, 122.43),
		v(907.46, 115.71),
		v(904.64, 108.99),
		v(902.14, 102.27),
		v(899.71, 95.42),
		v(897.54, 88.77),
		v(895.49, 81.98),
		v(893.38, 75.52),
		v(891.26, 68.99),
		v(889.09, 62.46),
		v(886.98, 56),
		v(884.61, 49.6),
		v(882.05, 43.14),
		v(879.1, 36.8),
		v(875.84, 30.72),
		v(872, 24.7),
		v(867.78, 19.33),
		v(862.98, 14.21),
		v(857.54, 9.79),
		v(851.46, 6.02),
		v(845.38, 2.56),
		v(839.36, -1.28),
		v(833.47, -5.25),
		v(827.78, -9.28),
		v(822.4, -13.95)
	},
	{
		v(687.1, -12.1),
		v(685.76, -5.12),
		v(684.22, 1.79),
		v(682.5, 8.64),
		v(680.7, 15.42),
		v(678.72, 22.08),
		v(676.61, 28.67),
		v(674.3, 35.26),
		v(671.81, 41.86),
		v(669.18, 48.26),
		v(666.11, 54.66),
		v(663.17, 60.8),
		v(659.78, 66.75),
		v(656.32, 72.45),
		v(652.42, 78.08),
		v(648.13, 83.33),
		v(643.33, 88.19),
		v(637.95, 92.67),
		v(631.94, 96.13),
		v(625.41, 98.5),
		v(618.43, 99.58),
		v(611.52, 99.52),
		v(604.48, 99.26),
		v(597.5, 98.69),
		v(590.53, 97.66),
		v(583.62, 96.26),
		v(576.83, 94.46),
		v(570.11, 92.35),
		v(563.46, 89.79),
		v(556.99, 86.91),
		v(550.66, 83.9),
		v(544.38, 80.64),
		v(538.43, 77.12),
		v(532.48, 73.79),
		v(526.59, 70.34),
		v(520.58, 67.07),
		v(514.24, 64.06),
		v(507.9, 61.44),
		v(501.31, 59.52),
		v(494.34, 58.43),
		v(487.36, 59.01),
		v(480.64, 61.12),
		v(474.5, 64.58),
		v(468.61, 68.8),
		v(463.3, 73.66),
		v(458.18, 78.78),
		v(453.25, 83.97),
		v(448.51, 89.09),
		v(443.9, 94.02),
		v(439.04, 98.82),
		v(433.92, 103.49),
		v(428.42, 107.71),
		v(422.53, 111.3),
		v(416.06, 113.66),
		v(409.15, 114.82),
		v(402.18, 113.98),
		v(395.39, 111.3),
		v(389.38, 107.33),
		v(383.94, 102.53),
		v(379.01, 97.34),
		v(374.4, 91.84),
		v(370.18, 86.14),
		v(366.14, 80.26),
		v(362.37, 74.24),
		v(358.66, 68.1),
		v(355.14, 62.08),
		v(351.87, 55.94),
		v(348.42, 50.05),
		v(345.09, 44.1),
		v(341.82, 38.08),
		v(338.24, 32.13),
		v(333.95, 26.24),
		v(329.28, 20.8),
		v(324.29, 15.74),
		v(319.1, 10.69),
		v(313.6, 6.08),
		v(307.97, 1.73),
		v(302.34, -2.37),
		v(296.45, -6.27),
		v(290.56, -10.11),
		v(284.54, -13.76)
	},
	{
		v(-12.86, 155.9),
		v(-5.76, 157.18),
		v(1.34, 158.66),
		v(8.19, 160.26),
		v(15.17, 161.98),
		v(22.02, 163.84),
		v(28.67, 165.89),
		v(35.2, 168.06),
		v(41.73, 170.43),
		v(48.13, 173.06),
		v(54.46, 176),
		v(60.54, 179.26),
		v(66.62, 182.91),
		v(72.26, 187.01),
		v(77.63, 191.62),
		v(82.3, 196.86),
		v(85.95, 202.69),
		v(88, 209.47),
		v(87.55, 216.58),
		v(84.93, 223.3),
		v(81.15, 229.44),
		v(76.74, 235.2),
		v(72.13, 240.77),
		v(67.46, 246.4),
		v(63.17, 251.97),
		v(59.71, 257.98),
		v(57.02, 264.45),
		v(56.06, 271.55),
		v(56.38, 278.66),
		v(57.73, 285.7),
		v(59.78, 292.8),
		v(62.14, 299.78),
		v(64.58, 306.5),
		v(66.94, 313.15),
		v(69.31, 319.68),
		v(71.42, 326.27),
		v(73.34, 332.99),
		v(74.75, 339.9),
		v(75.52, 346.82),
		v(75.39, 353.86),
		v(74.05, 360.83),
		v(71.04, 367.23),
		v(66.37, 372.61),
		v(60.03, 376.26),
		v(52.93, 378.62),
		v(46.21, 380.93),
		v(39.55, 383.42),
		v(33.22, 386.37),
		v(26.82, 389.44),
		v(20.67, 392.9),
		v(14.72, 396.61),
		v(9.09, 400.7),
		v(3.71, 405.25),
		v(-1.28, 410.24),
		v(-5.82, 415.68),
		v(-11.46, 420.54)
	}
}

for i, b in ipairs(bat_paths) do
	tt = E:register_t("decal_bat_flying_" .. i, "decal_bat_flying")
	local keys = {}
	local t = 0

	for _, p in pairs(b) do
		table.insert(keys, {
			t,
			p
		})

		t = t + bat_speed_per_node
	end

	tt.tween.props[1].keys = keys
	tt.delayed_play.play_duration = t
end

tt = E:register_t("decal_s24_nevermore", "decal_click_play")

E:add_comps(tt, "tween")

tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].scale = v(0.7, 0.7)
tt.render.sprites[1].prefix = "decal_s24_nevermore"
tt.render.sprites[1].z = Z_OBJECTS
tt.leave_time = 2
tt.main_script.update = scripts.decal_s24_nevermore.update
tt.sound = "ExtraBlackburnCrow"
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -10
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {
	{
		fts(0),
		v(0, 0)
	},
	{
		fts(60),
		v(334, 44)
	}
}
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect.pos.y = -26
tt = RT("decal_blackburn_weed", "decal_loop")
tt.render.sprites[1].random_ts = fts(34)
tt.render.sprites[1].name = "decal_blackburn_weed_idle"
tt = RT("decal_blackburn_waves", "decal_delayed_play")
tt.render.sprites[1].name = "decal_blackburn_waves_jump"
tt.delayed_play.min_delay = 0
tt.delayed_play.max_delay = 1
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_blackburn_waves_jump"
tt = RT("decal_blackburn_bubble", "decal_delayed_play")
tt.render.sprites[1].name = "decal_blackburn_bubble_jump"
tt.delayed_play.min_delay = 0
tt.delayed_play.max_delay = 1
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_blackburn_bubble_jump"
tt = RT("decal_blackburn_smoke", "decal_loop")
tt.render.sprites[1].random_ts = fts(21)
tt.render.sprites[1].name = "decal_blackburn_smoke_jump"
tt = E:register_t("decal_s25_nessie", "decal_click_play")
tt.render.sprites[1].anchor = v(0.5, 0.43478260869565216)
tt.render.sprites[1].prefix = "decal_s25_nessie"
tt.render.sprites[1].z = Z_OBJECTS
tt.main_script.update = scripts.decal_s25_nessie.update
tt.out_pos = {
	v(555, 600),
	v(131, 530),
	v(415, 450)
}
tt.animation_duration = {
	3,
	4
}
tt.pause_duration = {
	7,
	10
}
tt.sound = "ExtraBlackburnNessie"
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect.pos = v(-22, 2)
tt.ui.click_rect.size = v(30, 20)
tt = RT("decal_s26_cage", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_s26_cage"
tt.delayed_play.min_delay = 2
tt.delayed_play.max_delay = 6
tt.delayed_play.idle_animation = "idle"
tt.delayed_play.play_animation = "play"
tt = RT("decal_s26_hangmen", "decal_s26_cage")
tt.render.sprites[1].prefix = "decal_s26_hangmen"
tt = RT("decal_endless_burner", "decal_loop")
tt.render.sprites[1].name = "decal_orc_burner_idle"
tt.render.sprites[1].random_ts = fts(14)
tt = RT("decal_s81_percussionist", "decal_scripted")
tt.render.sprites[1].prefix = "decal_s81_percussionist"
tt.render.sprites[1].anchor.y = 0.125
tt.render.sprites[1].loop = false
tt.main_script.update = scripts.decal_s81_percussionist.update
tt.play_loops = 0
