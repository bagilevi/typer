module Typer
  class Application

    def initialize(options = {})
      default_files = Dir.glob(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lessons', '*.txt')))
      @lines = LineCollection.new(options[:file] || default_files)
    end

    def run
      catch :exit do
        trap("INT") { throw :exit }
        display_welcome
        loop do
          catch :next_line do
            exercise_line @lines.get_random
          end
        end
      end
      puts "\n"
    end

    def exercise_line line
      clear

      loop do
        display_line line
        wait_for_user_to_be_ready

        input_line, time = (read_line_with_time or throw :exit)

        if input_line == line
          clear

          speed = Speed.calculate(input_line, time)

          speed.influence_minimum!
          if speed.good?
            puts "GOOD! #{speed.long_string}  -  Next minimum: #{Speed.minimum}"
            wait_for_enter
            throw :next_line
          else
            display_retry "Too slow! Minimum: #{Speed.minimum}."
          end
        else
          display_retry "Incorrect."
        end
      end
    end

    def clear
      puts "\n" * 3
    end

    def display_welcome
      puts
      puts "typer - developer and sysadmin typing trainer"
      puts
      puts "The phrases are selected from all *.txt files in lessons directory and are combined so that a line length is between #{@lines.min_length} and #{@lines.max_length}"
      puts "The initial minimum is #{Speed.minimum.long_string} and will increase slowly depending on how fast you type."
      puts "Press ^C to exit."
      puts "Position your fingers over the home row and let the challenge begin!"
      wait_for_enter "start"
    end

    def display_line line
      print line
      $stdout.flush
    end

    def wait_for_user_to_be_ready
      sleep 1
      puts "\n"
    end

    def wait_for_enter action = "continue"
      puts
      sleep 1
      print "Press ENTER to #{action}...";
      $stdout.flush
      gets
    end

    def read_line_with_time
      s = nil
      t0 = Time.now
      s = $stdin.readline.strip
      t1 = Time.now
      t = (t1 - t0).to_f
      s ? [s, t] : nil
    rescue
      nil
    end

    def display_retry(reason)
      puts ">>> #{reason} Try again!\n"
      puts "\n\n"
    end

    def display_speed(speed)
      puts "CPM: #{speed}"
    end

  end

  class Speed
    @@min_cpm = 90

    def initialize(cpm)
      @cpm = cpm.to_i
    end

    def self.minimum=(min_cpm)
      @@min_cpm = min_cpm
    end

    def self.minimum
      self.new @@min_cpm
    end

    # Characters per minute
    def self.calculate input_line, time
      Speed.new( ((input_line.length / time.to_f) * 60).round )
    end

    def good?
      @cpm > @@min_cpm
    end

    def influence_minimum!
      @@min_cpm += ((@cpm - @@min_cpm) / 3).round
    end

    def to_s
      @cpm.to_s
    end

    def long_string
      "#{@cpm} hits per minute"
    end

    def method_missing(name, *args, &blk)
      ret = @cpm.send(name, *args, &blk)
    rescue
      super
    end
  end

  class LineCollection
    attr_accessor :min_length, :max_length, :input_files

    def initialize(input_files)
      @input_files = input_files
      @lines = []
      Array(input_files).each do |input_file|
        @lines += File.read(input_file).split("\n")
      end
      @min_length = 100
      @max_length = 140
    end

    def get_random
      line = ''
      while line.length < @min_length do
        max_diff = @max_length - line.length
        item = nil
        iter = 0
        while item.nil? || item.length > max_diff - 1 do
          i = rand(@lines.size)
          item = @lines[i].strip
          iter += 1
          if iter > 10
            item = @lines[i].strip[0..max_diff - 2]
          end
        end
        line = line.length == 0 ? item : line + ' ' + item
      end
      line
    end
  end
end


Typer::Application.new.run
