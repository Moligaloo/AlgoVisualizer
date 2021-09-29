moon_files = FileList['*.moon']
target_files = moon_files.map{ |file| 
    file "moonlua/#{File.basename file, '.moon'}.lua" => file do |t|
        sh "yue -t moonlua #{file}"
    end
}

task :default => target_files


