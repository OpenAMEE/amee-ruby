require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Profile::Item do
  
  it "should be able to create new profile items (XML)" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home/energy/quantity", {:profileDate=>Date.today.strftime("%Y%m")}).and_return('{"totalAmountPerMonth":105.472,"dataCategory":{"uid":"A92693A99BAD","path":"quantity","name":"Quantity"},"profileDate":"200809","path":"/home/energy/quantity","profile":{"uid":"E54C5525AA3E"},"children":{"pager":{"to":2,"lastPage":1,"start":0,"nextPage":-1,"items":2,"itemsPerPage":10,"from":1,"previousPage":-1,"requestedPage":1,"currentPage":1,"itemsFound":2},"dataCategories":[],"profileItems":{"rows":[{"created":"2008-09-03 11:37:35.0","kgPerMonth":"0","dataItemLabel":"gas","end":"false","uid":"FB07247AD937","modified":"2008-09-03 11:38:12.0","dataItemUid":"66056991EE23","validFrom":"20080902","amountPerMonth":"2.472","label":"ProfileItem","litresPerMonth":"0","path":"FB07247AD937","kWhPerMonth":"12","name":"gas"},{"created":"2008-09-03 11:40:44.0","kgPerMonth":"0","dataItemLabel":"gas","end":"false","uid":"D9CBCDED44C5","modified":"2008-09-03 11:41:54.0","dataItemUid":"66056991EE23","validFrom":"20080901","amountPerMonth":"103.000","label":"ProfileItem","litresPerMonth":"0","path":"D9CBCDED44C5","kWhPerMonth":"500","name":"gas2"}],"label":"ProfileItems"}}}')
    connection.should_receive(:post).with("/profiles/E54C5525AA3E/home/energy/quantity", :dataItemUid => '66056991EE23').and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileCategoryResource><ProfileItem created="Fri May 18 16:16:42 BST 2007" modified="Fri May 18 16:16:43 BST 2007" uid="782AC515F94B"><amountPerMonth>397.900</amountPerMonth><validFrom>20070501</validFrom><end>false</end><DataItem uid="66056991EE23"><name>29E52582826A</name><path>29E52582826A</path><label>gas</label></DataItem><name>782AC515F94B</name><ItemDefinition uid="B354BA63010D"/></ProfileItem></ProfileCategoryResource></Resources>')
    category = AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E/home/energy/quantity")
    item = AMEE::Profile::Item.create(category, '66056991EE23')
    item.should_not be_nil
  end
  
end
