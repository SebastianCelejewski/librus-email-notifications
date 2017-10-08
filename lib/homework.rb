module LibrusEmailNotifications
	class Homework
		attr_reader :id
		attr_reader :subject
		attr_reader :teacher
		attr_reader :topic
		attr_reader :category
		attr_reader :start_date
		attr_reader :end_date
		attr_reader :status
		attr_accessor :details

		def initialize(id, subject, teacher, topic, category, start_date, end_date, status)
			@id = id
			@subject = subject
			@teacher = teacher
			@topic = topic
			@category = category
			@start_date = start_date
			@end_date = end_date
			@status = status
		end

     	def to_json x
            {'id' => @id, 'subject' => @subject, 'teacher' => @teacher, 'topic' => @topic, 'category' => @category, 'start_date' => @start_date, 'end_date' => @end_date, 'status' => @status, 'details' => @details}.to_json 
        end
    
        def self.from_json string
            data = JSON.load string
            self.new data['id'], data['subject'], data['teacher'], data['topic'], data['category'], data['start_date'], data['end_date'], data['status'], data['details']
        end

        def self.from_hash data
            self.new data['id'], data['subject'], data['teacher'], data['topic'], data['category'], data['start_date'], data['end_date'], data['status'], data['details']
        end

        def ==(other)
            return id == other.id
        end        
	end
end