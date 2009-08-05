require 'clusters'

describe Clusters do
  it "convert formatted file to usable data" do
    col_row_data = Clusters.read_file("blogdata.txt")
    col_row_data.each { |item| item.class.should == Array }
    # p "col_row_data.inspect => #{col_row_data.inspect} -- clusters_spec.rb:7" #TRACE
  end
  
end