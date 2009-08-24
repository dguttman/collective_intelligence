require 'clusters'

describe Clusters do
  
  before do 
    @col_names, @row_names, @data = Clusters.read_file("blogdata.txt")
  end

  it "convert formatted file to usable data" do
    [@col_names, @row_names, @data].each { |item| item.class.should == Array }
    @col_names.each do |col_name|
      col_name.class.should == String
    end
    @row_names.each do |row_name|
      row_name.class.should == String
    end
    @data.each do |data_row|
      data_row.class.should == Array
      data_row.each { |value| value.class.should == Float }
    end
    # p "col_row_data.inspect => #{col_row_data.inspect} -- clusters_spec.rb:7" #TRACE
  end
  
  it "provide pearson correlation between vectors" do
    
    # Distance to self should be 0
    Clusters.pearson_dist(@data[0], @data[0]).should == 0.0
 
    # Distance should be reflexive
    Clusters.pearson_dist(@data[0], @data[1]).should == Clusters.pearson_dist(@data[1], @data[0])

    # Distance should fall within range of 2 >= d >= 0
    @data[1..-1].each_index do |i|
      r = Clusters.pearson_dist(@data[i], @data[i-1])
      r.should <= 2 && r.should >= 0
    end
  end

  describe "hierarchical clusters" do
    
    before do
      @cluster = Clusters.h_cluster(@data)
    end

    it "creates hierarchical cluster" do
      @cluster.class == Bicluster
    end

    it "prints clusters" do
      Clusters.print_cluster(@cluster, @col_names)
    end

    it "gets height of node" do  
      height = Clusters.get_height(@cluster)
      height.should >= 1
    end

    it "draws the dendrogram" do
      Clusters.draw_dendrogram(@cluster, @col_names, jpeg="test.png")
    end

  end

end
