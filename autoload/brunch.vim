" substitute function
function! s:sub(str,pat,rep)
  return substitute(a:str,'\v\C'.a:pat,a:rep,'')
endfunction

" Returns the modules's name extracted from the path
function! s:GetName(path)
  let path = matchlist(a:path, '\v([\a-z_]{-})(_controller)?(_view)?(_test)?\.')
  if empty(path)
    return a:path
  else
    return path[1]
  endif
endfunction

" Returns the path for a type with the module name.
function! s:PathForType(type, name, path)
  let type = a:type
  let name = a:name

  if type ==# 'model'
    return g:brunch_path_app . '/models/' .name. '.' .g:brunch_ext_script
  elseif type ==# 'view'
    return g:brunch_path_app . '/views/' .name. '_view.' .g:brunch_ext_script
  elseif type ==# 'controller'
    return g:brunch_path_app . '/controllers/' .name. '_controller.' .g:brunch_ext_script
  elseif type ==# 'template'
    return g:brunch_path_app . '/views/templates/' .name. '.' .g:brunch_ext_template
  elseif type ==# 'style'
    return g:brunch_path_app . '/views/styles/' .name. '.' .g:brunch_ext_stylesheet
  elseif type ==# 'test'
    " Replace app/ with test/ and add _test to each file name.
    let path = s:sub(a:path, g:brunch_path_app, g:brunch_path_test)
    let path = s:sub(path, '\.', '_test\.') 
    return path
  endif
endfunction


" Opens a file of the specific type (model, view, ...).
" Optional argument: the module name otherwise the name will be resolved
" from the current buffer.
function! s:FindBrunchFile(type, ...)
  " name/path given?
  if a:0 == 0
    let path = expand('%')
  else
    let path = a:1
  endif

  let name = s:GetName(path)
  return s:PathForType(a:type, name, path)
endfunction

" Opens a file for editing in the current buffer.
" Optional argument can be a string. 'v' for vsplit, 's' for split.
function! s:Edit(path, ...)
  if filereadable(a:path)
    if a:0 == 0
      let openMethod = 'edit'
    else
      let mode = a:1
      if mode ==? 'v'
        let openMethod = 'vsplit'
      elseif mode ==# 's'
        let openMethod = 'split'
      endif
    endif
    execute openMethod . ' ' . a:path
    return 1
  else 
    echo "File not found: " . a:path
  endif
endfunction

" Adds commands for file navigation in brunch.
function! s:NavCommands()
  " Add three open commands for each type: normal, horizontal split, vertical
  " split
  for type in ['model', 'view', 'controller', 'template', 'style', 'test']
    execute "command! -nargs=? B" .type. " :call s:Edit(s:FindBrunchFile('" .type. "', <f-args>))"
    execute "command! -nargs=? BV" .type. " :call s:Edit(s:FindBrunchFile('" .type. "', <f-args>), 'v')"
    execute "command! -nargs=? BS" .type. " :call s:Edit(s:FindBrunchFile('" .type. "', <f-args>), 's')"
  endfor

  command! -nargs=0 Bconfig    :call s:Edit('config.' . g:brunch_ext_script)
  command! -nargs=0 BVconfig   :call s:Edit('config.' . g:brunch_ext_script, 'v')
  command! -nargs=0 BSconfig   :call s:Edit('config.' . g:brunch_ext_script, 's')
  command! -nargs=0 Bindex     :call s:Edit(g:brunch_path_app . '/assets/index.html')
  command! -nargs=0 BVindex    :call s:Edit(g:brunch_path_app . '/assets/index.html', 'v')
  command! -nargs=0 BSindex    :call s:Edit(g:brunch_path_app . '/assets/index.html', 's')
endfunction


" Adds command interface to common brunch commands.
function! s:BrunchCommands()
  command! -nargs=*   Build    :echo system("brunch build " . <q-args>)
  command! -nargs=*   Bgenerate :echo system("brunch generate " . <q-args>)
  command! -nargs=*   Bdestroy  :echo system("brunch destroy " . <q-args>)
endfunction

call s:NavCommands()
call s:BrunchCommands()
