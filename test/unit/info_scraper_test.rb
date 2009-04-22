require 'test_helper'


class InfoScraperTest < ActiveSupport::TestCase
  
  context "The InfoScraper class" do
    setup do
      @scraper = InfoScraper.new()
    end
    
    should "not validate presence of :url" do
      @scraper.valid? # trigger validation
      assert_nil @scraper.errors[:url]
    end
    
    should "be subclass of Scraper class" do
      assert_equal Scraper, InfoScraper.superclass
    end
  end
  
  context "an InfoScraper instance" do
    setup do
      @scraper = Factory.create(:info_scraper)
    end
    
    should "search related model for related_objects when none exist" do
      related_objects = stub
      Member.expects(:find).with(:all, :conditions => {:council_id => @scraper.council_id}).returns("related_objects")
      assert_equal "related_objects", @scraper.related_objects
    end
    
    should "not search related model for related_objects when already exist" do
      @scraper.instance_variable_set(:@related_objects, "foo")
      Member.expects(:find).never
      assert_equal "foo", @scraper.related_objects
    end
    
    
    context "when processing" do
      context "with single given object" do
        setup do
          @scraper.stubs(:_data).returns("something")
          @parser = @scraper.parser
          @parser.stubs(:results).returns([{ :full_name => "Fred Flintstone", :url => "http://www.anytown.gov.uk/members/fred" }] )
          @dummy_related_object = Member.new(:url => "http://www.anytown.gov.uk/members/fred")
        end

        should "get data from object's url" do
          @scraper.expects(:_data).with("http://www.anytown.gov.uk/members/fred")
          @scraper.process(:objects => @dummy_related_object)
        end

        should "save in related_objects" do
          @scraper.process(:objects => @dummy_related_object)
          assert_equal [@dummy_related_object], @scraper.related_objects
        end

        should "return self" do
          assert_equal @scraper, @scraper.process(:objects => @dummy_related_object)
        end

        should "parse info returned from url" do
          @parser.expects(:process).with("something").returns(stub_everything(:results => []))
          @scraper.process(:objects => @dummy_related_object)
        end
        
        should "update existing instance of result_class" do
          @scraper.process(:objects => @dummy_related_object)
          assert_equal "Fred Flintstone", @dummy_related_object.full_name
        end
        
        should "not build new or update existing instance of result_class" do
          Member.expects(:build_or_update).never
          @scraper.process(:objects => @dummy_related_object)
        end
        
        should "validate existing instance of result_class" do
          @scraper.process(:objects => @dummy_related_object)
          assert @dummy_related_object.errors[:uid]
        end
        
        should "not try to save existing instance of result_class" do
          @dummy_related_object.expects(:save).never
          @scraper.process(:objects => @dummy_related_object)
        end
        
        should "try to save existing instance of result_class" do
          @dummy_related_object.expects(:save)
          @scraper.process(:save_results => true, :objects => @dummy_related_object)
        end
        
        should "store updated existing instance in results" do
          assert_equal [@dummy_related_object], @scraper.process(:objects => @dummy_related_object).results
        end
        
        context "and problem parsing" do

          should "not build or update instance of result_class if no results" do
            @parser.stubs(:results) # => returns nil
            Member.expects(:attributes=).never
            @scraper.process(:objects => @dummy_related_object)
          end
        end
      end
      
      context "with collection of given objects" do
        setup do
          @scraper.stubs(:_data).returns("something")
          @parser = @scraper.parser
          
          @dummy_object_1, @dummy_object_2 = Member.new, Member.new
          @dummy_collection = [@dummy_object_1, @dummy_object_2]
          @parser.stubs(:results).returns([{ :full_name => "Fred Flintstone", 
                                             :url => "http://www.anytown.gov.uk/members/fred" }] 
                                          ).then.returns([{ :full_name => "Barney Rubble", 
                                                           :url => "http://www.anytown.gov.uk/members/barney" }])
        end
      
        should "process url" do
          @scraper.expects(:process)
          @scraper.process(:objects => @dummy_collection)
        end
      
        should "save in related_objects" do
          @scraper.process(:objects => @dummy_collection)
          assert_equal @dummy_collection, @scraper.related_objects
        end
      
        should "return self" do
          assert_equal @scraper, @scraper.process(:objects => @dummy_collection)
        end
      
        should "update collection objects" do
          @scraper.process(:objects => @dummy_collection)
          assert_equal "Fred Flintstone", @dummy_object_1.full_name
          assert_equal "Barney Rubble", @dummy_object_2.full_name
        end
      
        should "not build new or update existing instance of result_class" do
          Member.expects(:build_or_update).never
          @scraper.process(:objects => @dummy_collection)
        end
      
        should "validate existing instance of result_class" do
          @scraper.process(:objects => @dummy_collection)
          assert @dummy_object_1.errors[:uid]
        end
      
        should "store updated existing instance in results" do
          assert_equal @dummy_collection, @scraper.process(:objects => @dummy_collection).results
        end
      
      end
      
      context "with no given objects" do
        setup do
          @member = Factory(:member)
          Member.stubs(:find).returns([@member])
          @scraper.stubs(:_data).returns("something")
          @parser = @scraper.parser
          
          @dummy_object_1, @dummy_object_2 = Member.new, Member.new
          @dummy_collection = [@dummy_object_1, @dummy_object_2]
          @parser.stubs(:results).returns([{ :full_name => "Fred Flintstone", 
                                             :url => "http://www.anytown.gov.uk/members/fred" }] 
                                          ).then.returns([{ :full_name => "Barney Rubble", 
                                                           :url => "http://www.anytown.gov.uk/members/barney" }])
        end
      
        should "use default related_objects" do
          Member.expects(:find).returns([@member])
          
          @scraper.process
          assert_equal [@member], @scraper.related_objects
        end
              
        should "not raise exception" do
          assert_nothing_raised() { @scraper.process }
        end
        
        should "update default related objects with parsed results" do
          @scraper.expects(:update_with_results).with(anything, @member, anything)
          @scraper.process
        end
      
      end

    end
  end
  
end
