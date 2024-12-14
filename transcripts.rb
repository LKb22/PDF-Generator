# Initialize the variables for the input and output files
#	  `input_dir` as the path to the 'Text' folder containing the `.srt` files
#   `output_file` as the name of the final PDF file, 'combined_transcript.pdf'

# Create an empty string to store the combined text from all `.srt` files
#   `combined_text`: Empty string to store all processed text

# Sort the `.srt` files based on the naming convention of the files
#   Retrieve all of the `.srt` files in the input directory
#   Extract the three sections: `C#`, `L#`, and the third number from filenames
#   Normalize the third number
#   Sort the files based on `C#`, `L#`, and the third number

# Debugging
#   Print the sorted order of files and their sorting keys to the console to verify the order

# Process the sorted files
#   For each file:
#      Read the content
#      Remove the timestamps (using regex)
#      Remove excess whitespace
#      Append the cleaned content into one combined text

# Generate a PDF
#   Use the prawn gem to create a PDF (Ruby library for PDF generation)
#   Set the page size and margins
#   Set the font and size
#   Add a title/header
#   Add the combined text with proper formatting as a string

# Output a success message


# Add gem and initialize variables
# Require gem: 'prawn' for PDF generation
require 'prawn'

# Directory containing the .srt files
input_dir = 'Text'

# Output PDF file
output_file = 'combined_transcript.pdf'

# Initialize the empty string variable for the cleaned content to be appended
combined_text = ""


# Sort the files
# Read all .srt files in the input directory (Text folder)
# Sort the files based on C, L, and third number sections in their names
# glob method returns an array of strings of filenames matching a specific pattern
files = Dir.glob("#{input_dir}/*.srt").sort_by do |file|
  # Extract the filename without the path
  filename = File.basename(file)

  # Find all of the files with filenames that match the pattern "C# - L# - ThirdNumber"
  match = filename.match(/C(\d+)[\s\-]+L(\d+)[\s\-]+([A-Za-z]?[\d\.]+)/)

  # When there is a match, extract the numeric value of each part
  # Save each parts numeric value. Use the indexes for C#, L#, and the third number part respectively
  # Use gsub to normalize the third part by removing "A"
  # convert to integers, third to float since some have decimals
  if match
    c_part = match[1].to_i                      # Extract C#
    l_part = match[2].to_i                      # Extract L#
    third_part = match[3].gsub(/^A/, '').to_f   # Normalize the third part (remove "A", handle decimals)

    # Return the sorting key
    # Combine the extracted values into an array for sorting
    [c_part, l_part, third_part]
  # If the format doesn't match, add these files last to find them easily in the terminal output
  else
    [Float::INFINITY] # Assign infinity value so these files appear last
  end
end


# Debug
# Print the sorted files and their sorting keys
if files.empty?
  puts "No files found in the directory or none matched the pattern."
else
  puts "Order of files to be processed:"
  files.each do |file|
    filename = File.basename(file)
    match = filename.match(/C(\d+)[\s\-]+L(\d+)[\s\-]+([A-Za-z]?[\d\.]+)/)
    if match
      c_part = match[1].to_i
      l_part = match[2].to_i
      third_part = match[3].gsub(/^A/, '').to_f
      puts "#{filename} -> [C: #{c_part}, L: #{l_part}, Third: #{third_part}]"
    else
      puts "#{filename} -> [Unmatched]"
    end
  end
end


# Append the content
# Clean up the content of each file and append the cleaned content into one combined text
files.each do |file|
  # Read the content of the file (each file)
  content = File.read(file)

  # Remove timestamps using a regex
  content.gsub!(/^\d+\s*\d{2}:\d{2}:\d{2},\d{3}\s*-->\s*\d{2}:\d{2}:\d{2},\d{3}/, '')

  # Remove extra whitespace: multiple spaces, tabs, and newlines
  content.gsub!(/\s+/, ' ')  # Replace multiple spaces with one
  content.strip!             # Remove leading/trailing whitespace

  # Append to the combined text
  combined_text += content + "\n\n" # Add two newlines to separate the content of each file into paragraphs using + "\n\n"
end


# Generate the PDF
# Use the Prawn gem to create a PDF file
# Set the page size and margins
Prawn::Document.generate(output_file, page_size: 'A4', margin: [50, 50, 50, 50]) do |pdf|
  # Set font and size
  pdf.font 'Helvetica', size: 12

  # Add a title
  pdf.text "Transcript of SRT Files", size: 16, style: :bold, align: :center
  pdf.move_down 20  # Adds space after the title

  # Add the combined text with improved formatting
  pdf.text combined_text, size: 12, leading: 4, align: :left
end

# Output a success message
puts "PDF generated: #{output_file}"
