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
  raw=raw.reject { |line| line.start_with?("#")}
  raw=raw.map { |line| line.strip.split(", ")}
  raw.each do |record|
    record=record.reject{ |x| x.empty?}
    hashrecords=Hash.new
    hashrecords[:type]=record[0]
    hashrecords[:target]=record[2]
    dnshash[record[1]]=hashrecords
  end
  return dnshash
end
def resolve(dns_records,lookup_chain,domain)
  rec=dns_records[domain]
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
