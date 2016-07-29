Dir.chdir(ENV['HOME'])

video_name = ARGV[0] || "./examples/input/IMG_1273.MOV"
output_video_name = "out_" + video_name
style = ARGV[1] || "examples/inputs/starry_night.jpg"
fps = "30.0"

Dir.chdir(ENV['HOME'] + "/input_data")
system "rm output*.png"
system %Q{ffmpeg -i #{video_name} -r #{fps} output_%04d.png}

Dir.chdir(ENV['HOME'])
input = Dir['input_data/output*'].sort
output = ENV['HOME'] + "/output_data"

Dir.chdir(ENV['HOME'] + '/source/neural-style/')

prev_frame = nil

input.each do |f|
  frame = f.split("/")[1].gsub("output", "frame")
  if prev_frame != nil
    system %Q{th neural_style.lua -init image -init_image #{output}/#{prev_frame} -style_image #{style} -content_image ~/#{f} -backend cudnn -cudnn_autotune }
  else
    system %Q{th neural_style.lua -style_image #{style} -content_image ~/#{f} -backend cudnn -cudnn_autotune }
  end
  prev_frame = frame
  system %Q{cp out.png #{output}/#{frame}}
end

Dir.chdir(ENV['HOME'] + "/input_data")
system %Q{cat frame*.png | ffmpeg -y -f image2pipe -r 1 -vcodec png -i - #{output_video_name}}
