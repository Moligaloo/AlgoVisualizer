moon_files = FileList['*.moon']
target_files = moon_files.map{ |file| 
    file "moonlua/#{File.basename file, '.moon'}.lua" => file do |t|
        sh "yue -t moonlua #{file}"
    end
}

task :default => target_files

task :package do |t|
    sh 'rm -rf build'
    sh 'mkdir build'
    sh 'cp *.lua moonlua/*.lua build'
    sh 'cp kai.ttf build'
    sh 'cd build && mv setup.lua main.lua && zip -rq AlgoVisualizer.love . && mv AlgoVisualizer.love ..'
    sh 'rm -rf build'
end
