levels = {
    {
        width = 96,
        height = 16,
        camera_mode = 1,
		music = 0,
		offset = 0
	},
	{
        width = 32,
        height = 32,
        camera_mode = 2,
		music = 0,
		offset = 312
    }
}

camera_modes = {

    -- 1: Intro
    function(px, py, g)
        if (px < 42) then
            camera_target_x = 0
        else
            camera_target_x = max(40, min(level.width * 8 - 128, px - 48))
        end
    end,

    -- 2: Intro 2
    function(px, py, g)
        if (px < 120) then
            camera_target_x = 0
        elseif (px > 136) then
            camera_target_x = 128
        else
            camera_target_x = px - 64
        end
        camera_target_y = max(0, min(level.height * 8 - 128, py - 64))
    end,

    -- 3: Basic Horizontal
    function(px, py, g)
        camera_target_x = max(0, min(level.width * 8 - 128, px - 56))
    end,

    -- 4: Basic Freeform
    function(px, py, g)
        camera_target_x = max(0, min(level.width * 8 - 128, px - 64))
        camera_target_y = max(0, min(level.height * 8 - 128, py - 64))
    end
}

have_grapple = true
camera_x = 0
camera_y = 0
camera_target_x = 0
camera_target_y = 0

snap_camera = function()
    camera_x = camera_target_x
    camera_y = camera_target_y
    camera(camera_x, camera_y)
end

tile_y = function(py)
    return max(0, min(flr(py / 8), level.height - 1))
end

function goto_level(index)

	-- set level
	level = levels[index]
	level_index = index

	-- load into ram
	local function vget(x, y) return peek(0x4300 + (x % 128) + y * 128) end
	local function vset(x, y, v) return poke(0x4300 + (x % 128) + y * 128, v) end
	px9_decomp(0, 0, 0x1000 + level.offset, vget, vset)

	-- start music
	music(level.music)
	
	-- load level contents
    restart_level()
end

function next_level()
	goto_level(level_index + 1)
end

function restart_level()
    camera_target_x = 0
	camera_target_y = 0
	objects = {}
	infade = 0
	camera(0, 0)

	for i = 0,level.width-1 do
		for j = 0,level.height-1 do
			for n=1,#types do
				if (tile_at(i, j) == types[n].tile and not is_collected(i, j)) then
					create(types[n], i * 8, j * 8)
				end
			end
		end
	end
end

-- gets the tile at the given location from the loaded level
function tile_at(x, y)
	if (single_level) then
		return mget(x, y)
	else
		return peek(0x4300 + (x % 128) + y * 128)
	end
end

function is_collected(x, y)
	return collected[x] and collected[x][y]
end

function set_collected(x, y)
	if (not collected[x]) then collected[x] = {} end
	collected[x][y] = true
end