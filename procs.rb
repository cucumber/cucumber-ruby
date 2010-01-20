p1 = lambda {}

p2 = lambda {
  
  
}

p3 = lambda {
  puts "hallo"
  
}

p4 = lambda do
  
  # hello
end

p5 = lambda do
  puts "hallo"
  
end

[p1, p2, p3, p4, p5].each do |p|
  path, line = *p.to_s.match(/[\d\w]+@(.+):(\d+).*>/)[1..2]
  puts line
end

def Given(re, &p)
  path, line = *p.to_s.match(/[\d\w]+@(.+):(\d+).*>/)[1..2]
  puts line
end

Given(/^whatever$/) {

  $before.should == true
  $step = true
}
