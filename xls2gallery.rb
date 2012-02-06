# -*- coding: gbk -*-

%w[benchmark pp rexml/document].each { |x| require x }
#encoding ��gbk
require 'sqlite3'
require 'win32ole'

class StorageAnalyser
  def initialize(xlsfile, outfile)
    @out_current_row = 1
    @xlsfile = xlsfile
    @table = 'storage'
    @outfile = outfile
    @xlCenter = -4108
    
    @table_sql = "create table #{@table} ( id INTEGER PRIMARY KEY,"
    @table_sql += 'xilie STRING,' # ϵ��
    @table_sql += 'store_date STRING,' # Ԥ�����
    @table_sql += 'onboard_date STRING,' # Ԥ������
    @table_sql += 'type_desc STRING,' # ��ʽ����
    @table_sql += 'design_num STRING,' # ��Ʊ��
    @table_sql += 'national_type STRING,' # ���ڿ��
    @table_sql += 'intl_type STRING,' # ���ʿ��
    @table_sql += 'size STRING,' # ���뷶Χ
    @table_sql += 'price STRING,' # ����
    @table_sql += 'color STRING,' # ��ɫ
    @table_sql += 'color_num NUMERIC,' # ��ɫ��
    @table_sql += 'order_num NUMERIC,' # ��������
    @table_sql += 'order_price NUMERIC,' # �������
    @table_sql += 'singapore_num NUMERIC,' # �¼��¶�����
    @table_sql += 'singapore_price NUMERIC,' # �¼��µ���
    @table_sql += 'macau_num NUMERIC,' # ���Ŷ�����
    @table_sql += 'macau_price NUMERIC,' # ���ŵ���
    @table_sql += 'sartre_num NUMERIC,' # ɳ�ض�����
    @table_sql += 'sartre_price NUMERIC);' # ɳ�ص���
    
    @db = SQLite3::Database.new(':memory:') #('store.db') (':memory:')
    @db.execute( @table_sql )
  end

  def create_style(workbook)   
    sty=workbook.Styles.Add('NormalStyle')     
    sty.Font.Size = 9
    sty.Borders.LineStyle=0
    sty.Borders(7).LineStyle=1     
    sty.Borders(8).LineStyle=1     
    sty.Borders(9).LineStyle=1     
    sty.Borders(10).LineStyle=1     
#    sty.Borders(11).LineStyle=0 # xlInsideHorizontal
#    sty.Borders(12).LineStyle=0 # xlInsideHorizontal
    
    sty=workbook.Styles.Add('TitleStyle')     
    sty.Font.Size = 9
    sty.Font.Bold =true     
    sty.Font.ColorIndex =3     
    #sty.Interior.ColorIndex = 20     
  end   

  def countDB
    puts 'Count database: '
    puts @db.execute( "select count(*) from #{@table}" )
  end
  
  def dumpDB
    puts 'Dump database:'
    @db.execute2( "select * from #{@table}" ) do |row|
      row.each {|it| print "#{it}," }
      print "\n"
    end
  end

  def fillDB(date='')
    # read xls file
    excel = WIN32OLE::new('excel.Application')
    workbook = excel.Workbooks.Open(@xlsfile)
    print "Total sheets: #{workbook.Worksheets.count}\n"
    @db.execute("BEGIN")
    workbook.Worksheets.each do |sheet|
      #skip sheets older than DB
      next if date >= sheet.name
      p "Processing sheet: #{sheet.name} ... "

      #sheet.Columns("A:H").Select
      #sheet.Selection.EntireColumn.Hidden = False
      i = 1
      prev_row = nil
      while true
        row = sheet.range("A#{i}:R#{i}").value[0] # N is the last column of storage sheet
        row.each {|it| it.encode!("gbk") if it.class == 'String' }
        prev_row = row if prev_row == nil

        # ending if there is no color and color_num
        break if row[0] == nil and row[9] == nil and row[10] == nil and row[12] == nil
        if row[9] == '��ɫ' or (row[12] != nil and row[9] == nil) # �����ͳ����
          # prev_row = nil
          i += 1
          next
        end

        # fill empty field
        0.upto(prev_row.count - 1) do |i|
          row[i] = prev_row[i] if row[i] == nil or row[i] == ''
        end
        
        # save row to DB
        insert = "insert into #{@table} values (NULL, "
        insert += " ?, ?, ?, ?, ?, "
        insert += " ?, ?, ?, ?, ?, "
        insert += " ?, ?, ?, ?, ?, "
        insert += " ?, ?, ?, ?"
        insert += ")"
        @db.execute(insert, row)
#        if i < 4
#          p prev_row
#          p row 
#        end
        
        prev_row = row
        i += 1
      end
      puts "done"

      # break      # for test, just analyse the first sheet.
    end 
    @db.execute("COMMIT")
    # remove useless record in DB
    excel.quit()
  end

  def genGallery
    outfile = WIN32OLE.new("excel.application")
    workbook = outfile.workbooks.add
    create_style(workbook)
    row = 1
    # write xls
    worksheet = workbook.Worksheets.Add
    worksheet.Activate
    # worksheet.name = xilie[0]
    
    xilies = @db.execute("select xilie from #{@table} group by xilie order by store_date")
    xilies.each do |xilie|
      xilie[0].encode!('gbk') if xilie[0].class == 'String'
      products = Hash.new
      records = @db.execute("select design_num, national_type, price, order_num, store_date, type_desc, intl_type, size, singapore_price, macau_price, sartre_price, color, color_num from #{@table} where xilie='#{xilie[0]}'")
      records.each do |record|
        record.each { |it| it.encode!('gbk') if it.class == 'String' }
        kuanhao = record[6]
        if products.has_key?(kuanhao)
          block = products[kuanhao]
          block[11..14].each do |it|
            next if it[0] != ''
            it[0] = record[11]
            it[1] = record[12]
            it[2] = record[3]
            break
          end
          block[3][1] = block[3][1].to_i + record[3].to_i # ����
          block[4][1] = block[2][1].to_i * block[3][1].to_i # ����ֵ
          block[15][2] = block[3][1]
        else
          block = Array.new
          block << ['��ƺ�', record[0], '', xilie[0],'']
          block << ['���ڿ��', record[1], '','','']
          block << ['���ڵ���', record[2], '','','']
          block << ['����', record[3], '','','']
          block << ['����ֵ', record[2].to_i*record[3].to_i, '','','']
          block << ['����ʱ��', record[4].to_s.split(' ')[0].gsub(/\//,' '), record[5],'','']
          block << ['���ʿ��', kuanhao, '','','']
          block << ['���뷶Χ', record[7], '','','']
          block << ['�����䷢����', '�¼���', '����','ɳ��','']
          block << ['���ⵥ��', record[8], record[9],record[10],'']
          block << ['��ɫ', 'ɫ��', '���ⶩ����','','']
          block << [record[11], record[12], record[3],'','']
          block << ['', '', '','','']
          block << ['', '', '','','']
          block << ['', '', '','','']
          block << ['�ϼ�', '', '',0,0]
          products[kuanhao] = block
        end
      end
      
      row = genGallerySheet(outfile, worksheet, xilie[0].encode('gbk'), products, row)
      #cells = outexcel.Range("a:z")
      #cells.Columns.AutoFit
    end
    
    cells = outfile.Range("A#{row}:T#{row}")
    cells.Merge
    cells.value = '2010��LC�ﶬ�¿��ͼ��                                                               ��1ҳ,��10ҳ'
    cells = outfile.Range("A#{row+1}:T#{row+1}")
    cells.Merge
    cells.value = '����Ӫ��������'

    workbook.saveas(@outfile)
    workbook.close    
    outfile.quit()
  end
  
  def genGallerySheet(outexcel, worksheet, xilie, products, start_row)
    p xilie
    cols = 4
    # д��xls�ļ�
    index = -1
    curr_row = start_row
    products.each_value do |value|
      index += 1
      curr_row = (index / cols) * 16 + start_row
      x_char = ('a'.getbyte(0) + index % cols * 5).chr
      xn_char = (x_char.getbyte(0) + 5 - 1).chr
      cells = outexcel.Range("#{x_char}#{curr_row}:#{xn_char}#{curr_row+15}")
      cells.value = value
      
      linestyle = 1
      #linestyle = 9 if block[6][1].force_encoding('gbk') == '2010�ﶬ'
      cells.Borders(7).LineStyle=linestyle
      cells.Borders(8).LineStyle=linestyle
      cells.Borders(9).LineStyle=linestyle
      cells.Borders(10).LineStyle=linestyle
      cells.style = 'NormalStyle'
      
      # picture
      image_path = "pictures\\#{value[1][1]}.jpg"
      if File.exist?(image_path)
        xmid_char = (x_char.getbyte(0) + 3 - 1).chr
        cell = outexcel.Range("#{xmid_char}#{curr_row+1}:#{xmid_char}#{curr_row+1}")
        cell.Select
        cell.value = image_path
        #worksheet.Pictures.Insert(image_path)
      end 
      
      # merge the last line of block
      #cells = outexcel.Range("#{x_char}#{curr_row+7}:#{xn_char}#{curr_row+7}")
      #cells.Merge
    end
    curr_row += 16
  end
  
end

#---------------------------main---------------------------------------------------
if ARGV[0] != nil
  infile = File.join(File.expand_path('.'), ARGV[0])
else
  puts " Usage: exe <filename>"
  exit
end
infile.gsub!(/\//, '\\')

parser = StorageAnalyser.new(infile, infile+'.gallery.xls')
result =  Benchmark.measure {
  parser.fillDB()
}
print "\nResult: #{result}\n"
# parser.dumpDB()
parser.countDB()
result =  Benchmark.measure {
  parser.genGallery()
}
print "\nResult: #{result}\n"

