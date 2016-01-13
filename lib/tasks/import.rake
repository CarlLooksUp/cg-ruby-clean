require 'csv'

namespace :import do
  desc "Import a CSV file full of business names"
  task :names, [:filename] => :environment do |t, args|
    f = File.open(args.filename)
    csv = CSV.new f, col_sep: "\t", headers: :first_row, converters: :all, force_quotes: true
    csv.to_a.map do |row|
      name_obj = NameObject.new
      name_obj.name = row["CogNameObjectName"]
      name_obj.likes = row["Likes"]
      name_obj.user = User.find_by beta_id: row["UserID"]
      biz = Business.new
      biz.location = row["Location"]
      biz.tagline = row["MeaningOrigin"]
      #biz.sic_code = row["BusinessType"]
      biz.entity_type = row["BusinessType"]
      biz.in_use = true
      biz.source = "user"
      biz.status = "no-proof"
      biz.website = row["Website"]

      biz.name_object = name_obj
      biz.save
    end
  end

  desc "Import a CSV file full of users"
  task :users, [:filename] => :environment do |t, args|
    f = File.open(args.filename)
    csv = CSV.new f, col_sep: "\t", headers: :first_row, converters: :all, force_quotes: true
    csv.to_a.map do |row|
      user = User.new
      user.username = row["Username"]
      user.name = row["UserFirstName"] + " " + row["UserLastName"]
      user.beta_id = row["UserID"]
      user.email = row["UserEmail"]
      user.password = "randomaccess"
      user.password_confirmation = "randomaccess"
      user.save
    end
  end

  desc "Split out location field into street, city, state, etc..."
  task :ma_locations => :environment do |t, args|
    Business.all.find_each do |biz|
      if /.*USA\Z/ =~ biz.location
        re = /(?<street>.*)\n(?<city>.*),\s*(?<state>[A-Z]{2})\s*(?<zip>\d{5}-?\d{4}?)?/
        loc = re.match(biz.location)
        if loc
          biz.address1 = loc[:street]
          biz.city = loc[:city]
          biz.state_code = loc[:state]
          biz.zip_code = loc[:zip]
          biz.save
        else
          puts biz.location
        end
      end
    end
  end

  desc "Import golf courses from CogNameObject csv"
  task :golf_courses, [:filename] => :environment do |t, args|
    f = File.open(args.filename)
    csv = CSV.new f, col_sep: "\t", headers: :first_row, converters: :all, force_quotes: true
    courses = {}
    csv.to_a.map do |row|
      if row["CategoryID"] == 19
        name = row["CogNameObjectName"]
        if /~/ =~ name
          sc = SubCourse.new
          sub_course = /(?<parent>.*?)\W*~\W*(?<name>.*?)/.match(name)
          sc.course_name = sub_course[:name]
          key = sub_course[:parent] + "" + row["City"] + "" + row["State"]
          gc = courses[key]
          puts "\"#{key}\""
          gc.sub_courses << sc
          gc.save
          sc.save
        else
          name_regex = /(?<name>.*\w)\W*$/.match(name) #trim ending whitespace
          name = name_regex[:name]
          name_obj = NameObject.new
          name_obj.name = name
          name_obj.likes = row["Likes"]
          name_obj.user = User.find_by beta_id: row["UserID"]
          gc = GolfCourse.new
          gc.city = row["City"]
          gc.state = row["State"]
          gc.country = row["Country"]
          gc.name_object = name_obj
          gc.save
          key = name + "" + row["City"] + "" + row["State"]
          courses[key] = gc
        end
      end
    end
  end

  desc "Import ski areas from CogNameObject csv"
  task :ski_areas, [:filename] => :environment do |t, args|
    f = File.open(args.filename)
    csv = CSV.new f, col_sep: "\t", headers: :first_row, converters: :all, force_quotes: true
    csv.to_a.map do |row|
      if row["CategoryID"] == 16
        name = row["CogNameObjectName"]
        name_regex = /(?<name>.*\w)\W*$/.match(name) #trim end whitespace
        name = name_regex[:name]
        name_obj = NameObject.new
        name_obj.name = name
        name_obj.likes = row["Likes"]
        name_obj.user = User.find_by beta_id: row["UserID"]
        sa = SkiArea.new
        sa.city = row["City"]
        sa.state = row["State"]
        sa.country = row["Country"]
        sa.name_object = name_obj
        sa.save
      end
    end
  end

  desc "Import radio stations from CogNameObject csv"
  task :radio_stations, [:filename] => :environment do |t, args|
    f = File.open(args.filename)
    csv = CSV.new f, col_sep: "\t", headers: :first_row, converters: :all, force_quotes: true
    csv.to_a.map do |row|
      if row["CategoryID"] == 23
        name = row["CogNameObjectName"].to_s
        name_regex = /(?<name>.*\w)\W*$/.match(name) #trim end whitespace
        name = name_regex[:name]
        name_obj = NameObject.new
        name_obj.name = name
        name_obj.likes = row["Likes"]
        name_obj.user = User.find_by beta_id: row["UserID"]
        rs = RadioStation.new
        rs.city = row["City"]
        rs.state = row["State"]
        rs.country = row["Country"]
        rs.format = row["CogNameType"]
        rs.frequency = row["SubNames"]
        rs.call_sign = row["CogNameCompany"]
        rs.name_object = name_obj
        rs.save
      end
    end
  end

  desc "Import candles from CogNameObject csv"
  task :candles, [:filename] => :environment do |t, args|
    f = File.open(args.filename)
    csv = CSV.new f, col_sep: "\t", headers: :first_row, converters: :all, force_quotes: true
    csv.to_a.map do |row|
      if row["CategoryID"] == 24
        name = row["CogNameObjectName"]
        name_regex = /(?<name>.*\w)\W*$/.match(name) #trim end whitespace
        name = name_regex[:name]
        name_obj = NameObject.new
        name_obj.name = name
        name_obj.likes = row["Likes"]
        name_obj.user = User.find_by beta_id: row["UserID"]
        candle = Candle.new
        candle.description = row["SubNames"]
        candle.company = row["CogNameCompany"]
        candle.collection = row["Nickname"]
        candle.name_object = name_obj
        candle.save
      end
    end
  end

  desc "Import NC businesses"
  task :nc_biz, [:filename] => :environment do |t, args|
    f = File.open(args.filename)
    entity_type_map = { LLC: "llc",
                        BUS: "corp",
                        LLP: "llp",
                        NP: "np",
                        BK: "",
                        PA: "pc",
                      }
    csv = CSV.new f, col_sep: "\t", headers: :first_row, converters: :all, force_quotes: true
    csv.to_a.map do |row|
      name_obj = NameObject.new
      name_obj.name = row["CorpName"]
      name_obj.likes = row["Likes"]
      name_obj.user = User.find_by beta_id: 3
      biz = Business.new
      biz.address1 = row["RegAddr1"]
      biz.address2 = row["RegAddr2"]
      biz.city = row["RegCity"]
      biz.state = row["RegState"]
      biz.zip_code = row["RegZip"]
      #biz.sic_code = row["BusinessType"]
      biz.entity_type = entity_type_map[row["BusinessType"]]
      biz.in_use = /Withdrawn|Dissolved|Cancelled/.match(row["Status"]).nil?
      biz.source = "state-corp"
      biz.status = "no-proof"

      biz.name_object = name_obj
      biz.save
    end
  end

  desc "Add serial numbers for all accounts"
  task :gen_serials => :environment do |t, args|
    Business.where("serial_number is not null").each do |biz|
      biz.generate_serial_number
      biz.save validate: false
    end
  end

  desc "Add state data to state table"
  task :populate_states => :environment do |t, args|
    states = Rails.cache.fetch('state_abbreviations_list') {
      f = File.open("data/state_abbreviations.json")
      state_abbreviations_list = JSON.parse f.read()
      f.close()
      state_abbreviations_list
    }

    states.each do |state|
      (State.new(state: state)).save
    end
  end

  desc "Match state fields to state rows in table"
  task :link_states => :environment do |t, args|
    silence_stream(STDOUT) do
      Business.where('state_code LIKE ?', '__').find_each do |biz|
        state = State.find_by state: biz.state_code
        biz.state = state
        biz.save validate: false
      end
    end
  end

  desc "Initialize the list of product types"
  task :product_types => :environment do |t, args|
    f = File.open("data/codes_no_hierarchy.json")
    codes_list_by_position = JSON.parse f.read()
    f.close()

    silence_stream(STDOUT) do
      codes_list_by_position.each do |pos, obj|
        unless obj['id'].nil?
          p = ProductType.new label: obj['label'].titleize, unspsc_id: obj['id']
          p.save
        end
      end
    end
  end

  desc "Set up parent relationships for UNSPSC product types"
  task :product_type_ancestry => :environment do |t, args|
    silence_stream(STDOUT) do
      ProductType.find_each do |pt|
        if pt.unspsc_id > 10000
          parent_id = pt.unspsc_id.to_s[0,4].to_i
          pt.parent = ProductType.find_by(unspsc_id: parent_id)
          pt.save
        end
      end
    end
  end

  desc "Set up parent relationships for IC product types"
  task :ic_codes => :environment do |t, args|
    f = File.open("data/product_types.json")
    ic_codes = JSON.parse f.read()
    ic_id = 0
    silence_stream(STDOUT) do
      ic_codes.each do |product_or_service, list|
        parent = ProductType.find_or_create_by(label: product_or_service)
        parent.save
        list.each do |ic_cat|
          child = ProductType.find_or_create_by(label: ic_cat['label'])
          child.parent = parent
          ic_id += 1
          child.ic_id = ic_id
          child.save
          ic_cat['children'].each do |unspsc_label|
            unspsc_code = ProductType.find_by(label: unspsc_label)
            unspsc_code.parent = child
            unspsc_code.save
          end
        end
      end
    end
  end
end
