#!/usr/bin/env ruby

require 'rubygems'
require 'bluecloth'

module MarkdownPreview
  OPEN_HTML     = 'open'
  PREVIEW_HTML  = "#{$HOME}/.preview.html"
  NAV_THRESHOLD = 4

  def self.run(argv)
    return print_usage if argv.size == 0
    html = File.open(PREVIEW_HTML, 'w')
    html.write(to_html(
      argv.map {|f| File.read(f)}.join("\n"),
      title_from_files(argv)))
    html.close
    `#{OPEN_HTML} #{html.path}`
  rescue StandardError => e
    puts e.message
  ensure
    html.close if html && !html.closed?
  end

  def self.print_usage
    puts "Usage: #{$0} [markdown-files,]"
  end

  def self.to_html(str, title = 'Preview')
    body, anchors = build_body_and_anchors(str)
    TEMPLATE.sub('$nav$', build_nav(anchors)).
      sub('$body$', body).
      sub('$class$', nav_class(anchors)).
      sub('$title$', title).
      gsub('<div class="section"></div>', '')
  end

  def self.build_body_and_anchors(str)
    html = BlueCloth.new(str).to_html
    anchors = []
    html.gsub!('<h1>', '</div><div class="section"><h1>')
    html.scan(/<h1>[^<]+<\/h1>/).each do |match|
      text = match.gsub(/<\/?h1>/, '')
      anchor = text.
        gsub(/[^a-zA-Z0-9\- ]/, '').
        gsub(/\s+/, '-').
        downcase
      anchors.push([anchor, text])
      html.sub!(match, 
        "<a class=\"fragment-anchor\" name=\"#{anchor}\"></a>#{match}")
    end
    [html, anchors]
  end

  def self.title_from_files(argv)
    File.basename(argv.first).
      gsub(/#{File.extname(argv.first)}$/, '').
      gsub(/[^a-zA-Z0-9\-_ ]/, '').
      gsub(/[\-_]/, ' ').
      split(/\s+/).
      map {|s| s.capitalize}.
      join(' ')
  end

  def self.nav_class(anchors)
    anchors.size <= NAV_THRESHOLD ? 'no-nav' : ''
  end

  def self.build_nav(anchors)
    return '' if anchors.size <= NAV_THRESHOLD
    html = ['<ul id="main-nav">']
    anchors.each do |anchor, text|
      html << "<li><a href=\"##{anchor}\">#{text}</a></li>"
    end
    html << '</ul>'
    html.join('')
  end

  TEMPLATE = <<-END_TEMPLATE
  <!doctype html>
  <head>
  <title>$title$</title>
  <style>
  html, body, div, span, object, iframe,h1, h2, h3, h4, h5, h6, p, blockquote, 
  pre,a, abbr, acronym, address, big, cite, code,del, dfn, em, img, ins, kbd, q, 
  s, samp,small, strike, strong, sub, sup, tt, var,dl, dt, dd, ol, ul, li,
  fieldset, form, label, legend,table, caption, tbody, tfoot, thead, tr, th, td { 
    margin: 0; padding: 0; border: 0; outline: 0; font-weight: inherit;
    font-style: inherit; font-family: lucida grande, helvetica, sans-serif;
    vertical-align: baseline; 
  }
  body { text-align: center; font-size: 11.5px; background: #e0e0e0;
    line-height: 1.7em; color: #333; width: 100%; height: 100%; }
  h1,h2,h3,h4,h5,h6 { font-weight: bold; font-family: myriad pro, sans-serif; }
  h1 { margin: 36px 0 24px; color: #111; border-bottom: 1px dashed #aaa; 
    padding-bottom: 6px; font-size: 2.2em; }
  h1 + p, h1 + ol, h1 + ul { margin-top: -12px; }
  h2, h3, h4, h5, h6 { margin: 24px 0; color: #111; }
  h2 + p, h2 + ol, h2 + ul,
  h3 + p, h3 + ol, h3 + ul,
  h4 + p, h4 + ol, h4 + ul,
  h5 + p, h5 + ol, h5 + ul,
  h6 + p, h6 + ol, h6 + ul { margin-top: -12px; }
  h2 { font-size: 1.8em; }
  h3 { font-size: 1.6em; }
  h3 { font-size: 1.4em; }
  h4 { font-size: 1.2em; }
  h5 { font-size: 1.1em; }
  h6 { font-size: 1em; }
  a { color: #a37142; text-decoration: none; }
  a:hover { color: #234f32; }
  .fragment-anchor + h1, h1:first-child { margin-top: 0; }
  select, input, textarea { font: 99% lucida grande, helvetica, sans-serif; }
  pre, code { font-family: monospace; }
  ol { list-style: decimal; }
  ul { list-style: disc; }
  ol, ul { margin: 24px 0 24px 1.7em; }
  p + ol, p + ul { margin-top: -16px; }
  ol:last-child, ul:last-child { margin-bottom: 0; }
  table { border-collapse: collapse; border-spacing: 0; }
  caption, th, td { text-align: left; font-weight: normal; }
  blockquote:before, blockquote:after,q:before, q:after { content: ""; }
  blockquote, q { quotes: "" ""; }
  em { font-style: italic; }
  strong { font-weight: bold; }
  p { margin: 24px 0; }
  p:first-child { margin-top: 0; }
  p:last-child { margin-bottom: 0; }
  #main { width: 500px; margin: 60px auto; text-align: left; position: relative;
    left: 100px; }
  .no-nav #main { left: 0; }
  .section { padding: 36px; background: #fff; border: 1px solid #bcbcbc; 
    -webkit-box-shadow: 2px 2px 4px #ccc; 
    -moz-box-shadow: 2px 2px 4px #ccc; margin-bottom: 36px; }
  .section pre { border-top: 1px solid #000; border-bottom: 1px solid #000;
     color: #fff; background: #555; width: 100%; padding: 12px 36px;
     position: relative; right: 36px; font-family: Monaco, monospace; }
  .section pre code { font-weight: normal; }
  .section code { font-family: Monaco, monospace; font-weight: bold; }
  .section strong { border-bottom: 1px dashed #aaa; }
  #main-nav { position: fixed; top: 40px; text-align: left; list-style: none; 
    text-align: right; margin-left: -170px; width: 240px; }
  #main-nav li { margin-bottom: 4px; }
  </style>
  </head>
  <body class="$class$">
    <div id="main">
      <div class="section">$body$</div>
      $nav$
    </div>
  </body>
  </html>
  END_TEMPLATE
end

MarkdownPreview.run(ARGV) if $0 == __FILE__
