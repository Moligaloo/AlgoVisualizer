Scene = require 'scene'
Button = require 'button'
Sprite = require 'sprite'

import floor from math

make_index = (row, column) -> row*10 + column

make_cities = (data) ->
    adjacent_matrix = {}
    city_names = {}

    set_distance = (f, to, distance) ->
        adjacent_matrix[f * 100 + to] = distance if distance
        
    for i, row in pairs data 
        for j, config in pairs row 
            index = make_index i,j
            city_names[index] = config.name

            set_distance index, make_index(i, j+1), config.east
            set_distance index, make_index(i+1, j), config.south
            set_distance index, make_index(i+1, j+1), config.southeast
            set_distance index, make_index(i+1, j-1), config.southwest

    city_names, adjacent_matrix

city_names, adjacent_matrix = make_cities {
    {
        nil,
        {name: '哈尔滨', east: 1},
        {name: '长春', east: 1},
        {name: '沈阳', east: 1.5, south: 3, southeast: 3.5},
        {name: '大连', south: 4}
    },
    {
        nil,
        nil,
        {name: '呼和浩特', east: 2, southwest: 7.5},
        {name: '北京', east: 0.5, south: 1},
        {name: '天津', southwest: 1.5, south: 1}
    },
    {
        {name: '乌鲁木齐', south: 9},
        {name: '银川', east: 6, south: 7.5, southeast: 3},
        {name: '太原', east: 1.5, south: 3, southeast: 2.5},
        {name: '石家庄', east: 2, south: 1.5},
        {name: '济南', south: 5, southwest: 3, east: 1.5},
        {name: '青岛', south: 5, southwest: 4.5}
    },
    {
        {name: '西宁', east: 1, south: 20},
        {name: '兰州', east: 2.5, south: 7},
        {name: '西安', east: 2, south: 4.5, southwest: 3},
        {name: '郑州', east: 3, south: 2, southeast: 2.5},
        {name: '南京', east: 1, south: 1, southeast: 1},
        {name: '上海', south: 1}
    },
    {
        {name: '拉萨'},
        {name: '成都', east: 1, southeast: 3},
        {name: '重庆', east: 6, south: 2},
        {name: '武汉', east: 1.5, south: 1, southeast: 2},
        {name: '合肥', east: 2, south: 4},
        {name: '杭州', south: 1, southwest: 2}
    },
    {
        nil,
        {name: '昆明', east: 2, southeast: 4},
        {name: '贵阳', east: 3, south: 5, southeast: 4},
        {name: '长沙', east: 1.5, south: 2.5},
        {name: '南昌', southeast: 3, south: 4.5},
        {name: '宁波', south: 3.5}
    },
    {
        nil,
        nil,
        {name: '南宁', east: 3},
        {name: '广州', south: 1, southwest: 10, southeast: 0.5},
        {name: '厦门', east: 1.5, south: 2.5},
        {name: '福州'}
    },
    {
        nil,
        nil,
        {name: '海口'},
        {name: '澳门'},
        {name: '深圳', east: 0.5},
        {name: '香港'}
    }
}

class Line extends Sprite
    draw: () =>
        with love.graphics
            .line @start_x, @start_y, @finish_x, @finish_y
            .printf(
                @distance, 
                (@start_x+@finish_x)/2+2, 
                (@start_y+@finish_y)/2-15,
                30
            )

class HSR extends Scene
    new: (config) =>
        super config

        origin_x = 30
        origin_y = 30
        width = 70
        height = 30
        h_gap = 60
        v_gap = 40

        getPos = (index) ->
            column = index % 10
            row = floor(index / 10)
            x = origin_x + (column - 1) * (width + h_gap)
            y = origin_y + (row - 1) * (height + v_gap)
            x, y
        
        for index, distance in pairs adjacent_matrix
            to = index % 100
            start_x, start_y = getPos floor index/100
            finish_x, finish_y = getPos to

            self\addSprite Line {
                start_x: start_x + width / 2
                start_y: start_y + height / 2
                finish_x: finish_x + width / 2
                finish_y: finish_y + height / 2
                :distance
            }
    
        for index, name in pairs city_names
            x, y = getPos index

            self\addSprite Button
                :x
                :y
                :width
                :height
                text: name

    switched: =>
        love.window.setTitle 'High Speed Railway'
