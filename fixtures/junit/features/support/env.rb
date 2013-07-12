Before do |row|
  row.class == Cucumber::Ast::OutlineTable::ExampleRow
  if (row.respond_to?("to_hash")) 
    site_lang = row.to_hash['skip']
    row.skip_invoke! if site_lang == 'skipping'
  end
end
