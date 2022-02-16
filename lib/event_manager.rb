require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'



def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone(phone)
    number = phone.gsub(/\D+/, '')
    if number.length == 10
        number
    elsif number.length == 11 && number.to_s.start_with?('1')
        number[1..9]
    else
        "Bad Number"
    end
end

def legislators_by_zipcode(zip)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

    begin
        legislators = civic_info.representative_info_by_address(
            address: zip,
            levels: 'country',
            roles: ['legislatorUpperBody', 'legislatorLowerBody']
        ).officials

        legislators_name = legislators.map(&:name)
        legislators_string = legislators_name.join(", ")
    rescue 
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end 
    
end

def save_thnak_you_letter(id, form_letter)
    Dir.mkdir('output') unless Dir.exit?('output')

    filename = "output/thanks_#{id}.html"

    File.open(filename, 'w') do |file|
        file.puts form_letter
    end
end

def open_csv
    CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)
end




puts "Event Manager initialized!"



def time_target
    contents = open_csv
    reg_hours = []
    contents.each do |row|
        reg_date = row[:regdate]
        reg_hour = Time.strptime(reg_date, "%m/%d/%Y %k:%M").strftime("%k")
        reg_hours.push(reg_hour)
    end
    occurance = reg_hours.reduce(Hash.new(0)) do |time, num|
        time[num] += 1
        time  
    end
    occurance.max_by { |k, v| v }[0]
end    

puts "The most visited hour is #{time_target}:00"

# template_letter = File.read('form_letter.erb')
# erb_template = ERB.new template_letter

# contents.each do |row|
    # id = row[0]
    
    # name = row[:first_name]
    
    # zipcode = clean_zipcode(row[:zipcode])
    
    # legislators = legislators_by_zipcode(zipcode)

    # phone_number = clean_phone(row[:homephone])
 
    # form_letter = erb_template.result(binding)

#     max_visited_hr = time_target(row[:regdate])
   
#     #save_thnak_you_letter(id, form_letter)
        
# end


