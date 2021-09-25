def get_command_line_argument
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end
domain = get_command_line_argument
dns_raw = File.readlines("zone")
def parse_dns(raw)
  dnshash=Hash.new
  raw=raw.reject { |line| line.strip.empty? }
  raw=raw.reject { |line| line.start_with?("#")}
  raw=raw.map { |line| line.strip.split(", ")}
  raw.each do |record|

    #puts "Record is "
    #puts record
    #puts "------------------------"
    #record=record.strip.split(", ")
    record=record.reject{ |x| x.empty?}
    #puts "---------------------"
    #puts "Record status : #{record.empty?}"
    #puts "Record[0] = #{record[0]} , Record[1]=#{record[1]}, Record[2]=#{record[2]}"

    #puts "---------------------"
    #if !(record.to_s.empty?)
    #hashrecords.map(:type=>record[0])
    hashrecords=Hash.new
    hashrecords[:type]=record[0]
    hashrecords[:target]=record[2]
    #key=record[1]

    #end
    #puts "------------------"
    #puts "Record type : #{hashrecords[:type]} , Value : #{record[0]}"
    #puts "Record target : #{hashrecords[:target]} , Value : #{record[2]}"
    #puts "hash key #{hashrecords[1]} , Value : #{hashrecords}"
    dnshash[record[1]]=hashrecords
    #puts "Hash records"

    #puts hashrecords
  end
  #puts dnshash[record[1].target]
  #puts "-----------"
  #puts dnshash
  return dnshash
end
def resolve(dns_records,lookup_chain,domain)
  rec=dns_records[domain]
  #puts rec
  if(!rec)
    lookup_chain << "Error: record not found for #{domain}"
  elsif rec[:type]=="A"
    lookup_chain << rec[:target]
  elsif rec[:type]=="CNAME"
    lookup_chain << rec[:target]
    resolve(dns_records,lookup_chain,rec[:target])
  end
end
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
