BruteSquad.configure :<%= plural_name %> do
  # singular   :<%= singular_name %>
  <%= '# ' if plural_name.singularize.classify == class_name %>class_name "<%= class_name %>"
  
  # session_domain ".example.com"
  session_secret "change me!"
end
