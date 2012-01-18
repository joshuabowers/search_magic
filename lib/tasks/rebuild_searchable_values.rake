namespace :search_magic do
  desc "Updates each SearchMagic document's :searchable_values array"
  task :rebuild => :environment do |t, args|
    Module.constants.map {|c| Module.const_get(c)}.select {|c| c.class == Class && c < SearchMagic}.each do |document|
      document.all.each {|d| d.save!}
    end
  end
end