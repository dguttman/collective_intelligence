class Clusters
  
  def self.read_file(filename)
    lines = File.open(filename, "r").readlines
    
    # First line is the column titles
    col_names = lines[0].strip.split("\t")[1..-1]
    row_names = []
    data = []
    
    lines[1..-1].each do |line|
      p = line.strip.split("\t")
      # First column in each row is the row name
      row_names << p[0]
      # The data for this row is the remainder of the row
      p[1..-1].each do |x|
        data << x.to_f
      end
    end
    
    return row_names, col_names, data
  end
  
end