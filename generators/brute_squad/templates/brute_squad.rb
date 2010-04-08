BruteSquad.configure :<%= model_name %> do
  <%= '# ' if model_name.singularize == singular_name       %>singular   "<%= singular_name %>"
  <%= '# ' if model_name.singularize.classify == class_name %>class_name "<%= class_name %>"
end
