-- ant colony optimization
local Scene = require 'scene'
local Sprite = require 'sprite'

local function make_index(row, column)
    return row * 10 + column
end

local function make_cities(data)
    local adjacent_matrix = {}
    local city_names = {}

    local function set_distance(from, to, distance)
        if distance then
            adjacent_matrix[from * 100 + to] = distance
        end
    end

    for i, row in pairs(data) do
        for j, config in pairs(row) do
            local index = make_index(i, j)
            city_names[index] = config.name

            set_distance(index, make_index(i, j + 1), config.east)
            set_distance(index, make_index(i + 1, j), config.south)
            set_distance(index, make_index(i + 1, j + 1), config.southeast)
            set_distance(index, make_index(i + 1, j - 1), config.southwest)
        end
    end

    return city_names, adjacent_matrix
end

local city_names, adjacent_matrix = make_cities {
    {
        nil,
        {name = '哈尔滨', east = 1},
        {name = '长春', east = 1},
        {name = '沈阳', east = 1.5, south = 3, southeast = 3.5},
        {name = '大连', south = 4}
    },
    {
        nil,
        nil,
        {name = '呼和浩特', east = 2, southwest = 7.5},
        {name = '北京', east = 0.5, south = 1},
        {name = '天津', southwest = 1.5, south = 1}
    },
    {
        {name = '乌鲁木齐', south = 9},
        {name = '银川', east = 6, south = 7.5, southeast = 3},
        {name = '太原', east = 1.5, south = 3, southeast = 2.5},
        {name = '石家庄', east = 2, south = 1.5},
        {name = '济南', south = 5, southwest = 3, east = 1.5},
        {name = '青岛', south = 5, southwest = 4.5}
    },
    {
        {name = '西宁', east = 1, south = 20},
        {name = '兰州', east = 2.5, south = 7},
        {name = '西安', east = 2, south = 4.5, southwest = 3},
        {name = '郑州', east = 3, south = 2, southeast = 2.5},
        {name = '南京', east = 1, south = 1, southeast = 1},
        {name = '上海', south = 1}
    },
    {
        {name = '拉萨'},
        {name = '成都', east = 1, southeast = 3},
        {name = '重庆', east = 6, south = 2},
        {name = '武汉', east = 1.5, south = 1, southeast = 2},
        {name = '合肥', east = 2, south = 4},
        {name = '杭州', south = 1, southwest = 2}
    },
    {
        nil,
        {name = '昆明', east = 2, southeast = 4},
        {name = '贵阳', east = 3, south = 5, southeast = 4},
        {name = '长沙', east = 1.5, south = 2.5},
        {name = '南昌', southeast = 3, south = 4.5},
        {name = '宁波', south = 3.5}
    },
    {
        nil,
        nil,
        {name = '南宁', east = 3},
        {name = '广州', south = 1, southwest = 10, southeast = 0.5},
        {name = '厦门', east = 1.5, south = 2.5},
        {name = '福州'}
    },
    {
        nil,
        nil,
        {name = '海口'},
        {name = '澳门'},
        {name = '深圳', east = 0.5},
        {name = '香港'}
    }
}

local ACO = Scene:subclass 'ACO'
local Button = require 'button'

local Line = Sprite:subclass 'Line'

function Line:draw()
    love.graphics.line(self.start_x, self.start_y, self.finish_x, self.finish_y)
    love.graphics.printf(tostring(self.distance),
                         (self.start_x + self.finish_x) / 2 + 2,
                         (self.start_y + self.finish_y) / 2 - 15, 30)
end

function ACO:initialize(config)
    Scene.initialize(self, config)

    self.title = 'Ant Colony Optimization'

    local origin_x = 30
    local origin_y = 30
    local width = 70
    local height = 30
    local h_gap = 60
    local v_gap = 40

    local function getPos(index)
        local column = index % 10
        local row = math.floor(index / 10)
        local x = origin_x + (column - 1) * (width + h_gap)
        local y = origin_y + (row - 1) * (height + v_gap)
        return x, y
    end

    for index, distance in pairs(adjacent_matrix) do
        local from = math.floor(index / 100)
        local to = index % 100
        local start_x, start_y = getPos(from)
        local finish_x, finish_y = getPos(to)

        table.insert(self.sprites, Line {
            start_x = start_x + width / 2,
            start_y = start_y + height / 2,
            finish_x = finish_x + width / 2,
            finish_y = finish_y + height / 2,
            distance = distance
        })
    end

    for index, name in pairs(city_names) do
        local x, y = getPos(index)

        table.insert(self.sprites, Button {
            x = x,
            y = y,
            width = width,
            height = height,
            text = name
        })
    end

end

return ACO()

