class DashboardController < ApplicationController
	
	def home 
		@java_file = JavaFile.new
		@java_files = JavaFile.all
	end

	def show
		@java_file = JavaFile.find(params[:id])
	end

	def upload
		@java_files = JavaFile.all
		@java_file = JavaFile.new
		uploaded_io = java_file_params[:path_file]
		new_path_file = Rails.root.join('java_files', uploaded_io.original_filename)
		File.open(new_path_file, 'wb') do |file|
			file.write(uploaded_io.read)
		end
		if @java_file.update(path_file: new_path_file, compile: java_file_params[:compile])
			redirect_to show_path(@java_file)
		else 
			render :home
		end
	end

	private 

	def java_file_params
		params.require(:java_file).permit(:path_file, :compile)
	end

end
