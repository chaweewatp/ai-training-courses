module ApplicationHelper
  def markdown(text)
    renderer = Redcarpet::Render::HTML.new(
      hard_wrap: true,
      fenced_code_blocks: true,
      autolink: true
    )
    markdown = Redcarpet::Markdown.new(renderer, fenced_code_blocks: true)
    html = markdown.render(text.to_s)
    highlighted = highlight_code_blocks(html)
    highlighted.html_safe
  end

  private

  def highlight_code_blocks(html)
    html.gsub(%r{<pre><code(?: class="(?:language-)?([\w+-]+)")?>(.*?)</code></pre>}m) do
      lang = Regexp.last_match(1) || "text"
      code = CGI.unescapeHTML(Regexp.last_match(2))
      lexer = Rouge::Lexer.find_fancy(lang, code) || Rouge::Lexers::PlainText
      highlighted = Rouge::Formatters::HTML.new.format(lexer.lex(code))
      %(<div class="code-block"><div class="code-head"><span>#{lang}</span><button type="button" class="copy-btn" data-copy>Copy</button></div><pre><code>#{highlighted}</code></pre></div>)
    end
  end
end
