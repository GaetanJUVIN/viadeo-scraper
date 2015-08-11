#encoding: utf-8

##
## profile.rb
## Gaetan JUVIN 08/07/2015
##

module Viadeo
  class Profile

    USER_AGENTS = ['Windows IE 6', 'Windows IE 7', 'Windows Mozilla', 'Mac Safari', 'Mac FireFox', 'Mac Mozilla', 'Linux Mozilla', 'Linux Firefox', 'Linux Konqueror']

    ATTRIBUTES = %w(name first_name last_name title location country industry summary keywords picture viadeo_url education groups websites languages skills social_links certifications organizations past_companies current_companies recommended_visitors)

    attr_reader :page, :viadeo_url

    def self.get_profile(url,options = {})
          Viadeo::Profile.new(url,options)
    end

    def initialize(url, options = {})
      @viadeo_url = url
      @options = options
      @page         = http_client.get(url)
#        @page.search(".blockitemEmployment/.gu-date/\.stillInfalse").map{|n| n.parent().parent()}.each do |node|
#	pp node.at('.itemName')['href'] if node.at('.itemName')
#	end
    end

    def name
      "#{first_name} #{last_name}"
    end

    def first_name
      @first_name ||= (@page.at('.firstname').text.strip if @page.at('.firstname'))
    end

    def last_name
      @last_name ||= (@page.at('.lastname').text.strip if @page.at('.lastname'))
    end

    def title
      @title ||= (@page.at('.bd/h3').text.gsub(/\s+/, ' ').strip if @page.at('.bd/h3'))
    end

    def location
      @location ||= (@page.at('.location > span[itemprop="addresslocality"]').text.split(',').first.strip if @page.at('.location > span[itemprop="addresslocality"]'))
    end

    def country
      @country ||= (@page.at('.location > span[itemprop="addressCountry"]').text.split(',').last.strip if @page.at('.location > span[itemprop="addressCountry"]').text.blank? == false)
    end

    def industry
	##TODO
#      @industry ||= (@page.at('.industry').text.gsub(/\s+/, ' ').strip if @page.at('.industry'))
    end

    def summary
      @summary ||= (@page.at('.detailResume').text.gsub(/\s+/, ' ').strip if @page.at('.detailResume'))
    end

    def picture
      @picture ||= (@page.at('.avatar/img').attributes['src'].value.strip if @page.at('.avatar/img'))
    end

    def skills
      @skills ||= (@page.search('.allListSkillsContent // li').map{|skill| skill.text.strip if skill.text} rescue nil)
    end

    def past_companies
      @past_companies ||= get_companies('stillInfalse')
    end

    def current_companies
      @current_companies ||= get_companies('stillIntrue')
    end
    def keywords
      @keywords ||= @page.search('.keywords//.bubbleText').map do |item|
        item.text.gsub(/\s+|\n/, ' ').strip
      end
    end

    def education
       @education ||= @page.search('.blockitemEducation').map do |item|
        name      = item.at('span[itemprop="name"]').text.gsub(/\s+|\n/, ' ').strip     if item.at('span[itemprop="name"]')
        desc      = item.at('.type').text.gsub(/\s+|\n/, ' ').strip                     if item.at('.type')
        p item.at('.start-date').text
        startDate = parse_date(item.at('.start-date').text.gsub(/\s+|\n/, ' ').strip)   if item.at('.start-date')
        endDate   = parse_date(item.at('.end-date').text.gsub(/\s+|\n/, ' ').strip)     if item.at('.stillIntrue') == nil and item.at('.end-date')

        {:name => name, :description => desc, :startDate => startDate, :endDate => endDate}
      end
    end

    def social_links
      @social_links ||= @page.search('#target_sociallinks/li').map do |item|
        link = item.css('a').first
        img = item.css('img').first
        link_url = link['href'] if link
        name = img['class'].split(' ').select { |klass| klass =~ /logo(\w+)/ }[0].gsub('logo', '') if img
        {name: name, link: link_url}
      end
    end

    def websites

	#TODO
      @websites ||=  @page.search('.website').flat_map do |site|
        url = "http://www.linkedin.com#{site.at('a')['href']}"
        CGI.parse(URI.parse(url).query)['url']
      end

    end

    def groups
      @groups ||= @page.search('.boxFollowGroup//a').map do |item|
        name = item.text.gsub(/\s+|\n/, ' ').strip
        link = item['href']
        {:name => name, :link => link}
      end
    end

    def organizations
    end

    def languages
      @languages ||= @page.search('.spoken-languages//span.name').map do |item|
        language    = item.text.strip rescue nil
        proficiency = item.parent.at('div/div')['class'].split(' ').first[-1,1]
        {:language=> language, :proficiency => proficiency }
      end
    end

    def certifications
=begin
##TODO
        @certifications ||= @page.search('ul.certifications/li.certification').map do |item|
            name       = item.at('h3').text.gsub(/\s+|\n/, ' ').strip                         rescue nil
            authority  = item.at('.specifics/.org').text.gsub(/\s+|\n/, ' ').strip            rescue nil
            license    = item.at('.specifics/.licence-number').text.gsub(/\s+|\n/, ' ').strip rescue nil
            start_date = item.at('.specifics/.dtstart').text.gsub(/\s+|\n/, ' ').strip        rescue nil

            {:name => name, :authority => authority, :license => license, :start_date => start_date}
          end
=end
    end

    def recommended_visitors
      @recommended_visitors ||= @page.search('.contact-list//li.contact').map do |visitor|
        v = {}
        v[:link]    = visitor.at('a')['href']
        v[:name]    = visitor.at('.bd/h4.fullname/a').text
        v[:title]   = visitor.at('.headline').text.gsub('...',' ').split(/(, | at ){1}/).first.strip rescue nil
        v[:company] = visitor.at('.headline').text.gsub('...',' ').split(/(, | at ){1}/)[2..-1].join.strip rescue nil
        v
      end
    end

    def to_json
      require 'json'
      ATTRIBUTES.reduce({}){ |hash,attr| hash[attr.to_sym] = self.send(attr.to_sym);hash }.to_json
    end


    private

    def get_companies(type)
## blockitemEmployment class date stillIntrue
      companies = []
      if @page.search(".blockitemEmployment/.gu-date/\.#{type}").map{|n| n.parent().parent()}.first 
        @page.search(".blockitemEmployment/.gu-date/\.#{type}").map{|n| n.parent().parent()}.each do |node|

          company               = {}
          company[:title]       = node.at('.titre').text.gsub(/\s+|\n/, ' ').strip if node.at('.titre')
          if node.css('.title .bd .cf').any?
            company[:company]   = node.css('.title .bd .cf').text.gsub(/\s+|\n/, ' ').strip
            company_size = node.css('.title .bd div').text.gsub(/\s+|\n/, ' ').strip.gsub(company[:company], '')

            company[:size]      = company_size                                     if company_size.blank? == false
          end
          company[:description] = node.at(".description").text.gsub(/\s+|\n/, ' ').strip if node.at(".description")

          start_date  = node.at('.start-date').text.gsub(/\s+|\n/, ' ').strip rescue nil
          company[:start_date] = parse_date(start_date) rescue nil

          if node.at('.stillIntrue')
            company[:end_date] = nil
          else
            end_date = node.at('.end-date').text.gsub(/\s+|\n/, ' ').strip rescue nil
            company[:end_date] = parse_date(end_date) rescue nil
          end

  	  company_link = node.at('.itemName')['href'] if node.at('.itemName')
  	  if company_link =~ /\/company\//
            result = get_company_details(company_link)
            companies << company.merge!(result)
  	  else
  	  companies << company
	  end
        end
      end
      companies
    end

    def parse_date(date)
      return nil if date.blank?
      date = "#{date}-01-01" if date =~ /^(19|20)\d{2}$/
      Date.parse_international(date)
    end

    def get_company_details(link)
      result = {:viadeo_company_url => link}
      page = http_client.get(result[:viadeo_company_url])

      result[:url] = page.at('.website')['href'] if page.at('.website')
      node_2 = page.at('.basic-info/.content.inner-mod')
      if node_2
        node_2.search('dd').zip(node_2.search('dt')).each do |value,title|
          result[title.text.gsub(' ','_').downcase.to_sym] = value.text.strip
        end
      end
      result[:address] = page.at('.vcard.hq').at('.adr').text.gsub("\n",' ').strip if page.at('.vcard.hq')
      result
    end

    def http_client()
      Mechanize.new do |agent|
        agent.user_agent_alias = USER_AGENTS.sample
        unless @options.empty?
          agent.set_proxy(@options[:proxy_ip], @options[:proxy_port])
        end
        agent.max_history = 0
      end
    end

  end
end
