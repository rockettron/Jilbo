class HalstedController < ApplicationController

	def index
		@java_file = Halsted.new
		@java_files = Halsted.all
	end

	def show
		@java_file = Halsted.find(params[:id])
	end

	def upload
		@java_file = Halsted.new
		@java_files = Halsted.all
		uploaded_io = java_file_params[:path_file]
		new_path_file = Rails.root.join('java_files', uploaded_io.original_filename)
		File.open(new_path_file, 'wb') do |file|
			file.write(uploaded_io.read)
		end
		if @java_file.update(path_file: new_path_file, compile: java_file_params[:compile])
			redirect_to halsted_path(@java_file)
		else 
			render :index
		end
	end

	private 

	def java_file_params
		params.require(:halsted).permit(:path_file, :compile)
	end

end
