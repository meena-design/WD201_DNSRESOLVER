def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")


# parse_dns to return dns as records - hash
def parse_dns(dnsstring)
  #remove empty lines
  dnsstring=dnsstring.reject { |s| s.strip.empty? }
  # removing first hash line
  dnsstring=dnsstring[1..-1]
  # creating empty hash
  dnsreturn={}
  for i in 0..dnsstring.length-1 do
    temp=dnsstring[i].split(",")
    temphash= Hash.new
    temphash[:type]=temp[0].strip
    temphash[:target]=temp[2].strip
    dnsreturn[temp[1].strip]=temphash
  end
  return(dnsreturn)
end

# dns resolver
def resolve(dns_records,lookup_chain,domain)
  rec=dns_records[domain]
  if !(rec)
    errorMessage = "Error: record not found for "+domain.to_s
    lookup_chain.push(errorMessage)
  elsif rec[:type]=="A"
    lookup_chain.push(rec[:target])
  elsif rec[:type]=="CNAME"
    lookup_chain.push(rec[:target])
    resolve(dns_records,lookup_chain,rec[:target])
  end
end


dns_records = parse_dns(dns_raw)
lookup_chain = [domain]

lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
