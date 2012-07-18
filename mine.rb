



def buildDataStructures
  
end

def ds
  build_and_save('juliussmall.json')
end

def dl
  return_load('juliussmall.json')
end

def build_and_save(fname)
  keywords = buildDataStructures
  File.open(fname ,'w') do |f|
    f.write(keywords.to_json)
  end
  keywords
end

def return_load(fname)
  File.open( fname, 'r') do |f|
    JSON.load(f)
  end
end

