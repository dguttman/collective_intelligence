require 'generate_feed_vector'

SAMPLE_HTML = "<div class=\"method-description\"><p>
Packs the contents of <em>arr</em> into a binary sequence according to the
directives in <em>aTemplateString</em> (see the table below) Directives
``A,’’ ``a,’’ and ``Z’’ may be followed
by a count, which gives the width of the resulting field. The remaining
directives also may take a count, indicating the number of array elements
to convert. If the count is an asterisk (``<tt>*</tt>’’), all
remaining array elements will be converted. Any of the directives
``<tt>sSiIlL</tt>’’ may be followed by an underscore
(``<tt>_</tt>’’) to use the underlying platform‘s native
<a href=\"Array.html#M002221\">size</a> for the specified type; otherwise,
they use a platform-independent <a href=\"Array.html#M002221\">size</a>.
Spaces are ignored in the template string. See also <tt><a href=\"String.html#M000760\">String#unpack</a></tt>.
</p><p>Directives for <tt><a href=\"Array.html#M002222\">pack</a></tt>.
</p></div>"
        
SAMPLE_HTML_WORDS = ["", "packs", "the", "contents", "of", "arr", "into", "a", "binary", "sequence", "according", "to", "the", "directives", "in", "atemplatestring", "see", "the", "table", "below", "directives", "a", "a", "and", "z", "may", "be", "followed", "by", "a", "count", "which", "gives", "the", "width", "of", "the", "resulting", "field", "the", "remaining", "directives", "also", "may", "take", "a", "count", "indicating", "the", "number", "of", "array", "elements", "to", "convert", "if", "the", "count", "is", "an", "asterisk", "all", "remaining", "array", "elements", "will", "be", "converted", "any", "of", "the", "directives", "ssiill", "may", "be", "followed", "by", "an", "underscore", "to", "use", "the", "underlying", "platform", "s", "native", "size", "for", "the", "specified", "type", "otherwise", "they", "use", "a", "platform", "independent", "size", "spaces", "are", "ignored", "in", "the", "template", "string", "see", "also", "string", "unpack", "directives", "for", "pack"]

SAMPLE_URL = "http://www.joelonsoftware.com/rss.xml"

describe FeedVectorGenerator do 
  before do
    
  end
  
  it "should get word counts" do
    word_counts = FeedVectorGenerator.get_word_counts(SAMPLE_URL)
    word_counts.class.should == Array
    
    feed_title = word_counts[0]
    feed_title.class.should == String
    
    counts = word_counts[1]
    counts.class.should == Hash
    
    counts.keys.map { |k| k.class.should == String }
    counts.values.map { |v| v.class.should == Fixnum }
    
  end
  
  it "should get words from html" do
    FeedVectorGenerator.get_words(SAMPLE_HTML).should == SAMPLE_HTML_WORDS
  end
  
  it "should generate blogdata file" do
    FeedVectorGenerator.create_matrix(File.open("feedlist.txt", "r").readlines[0..10], "blogdata")
  end
  
end

