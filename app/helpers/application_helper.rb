module ApplicationHelper
  def markdown(text)
    doc = Kramdown::Document.new(
      text.to_s,
      input: "GFM",
      hard_wrap: true,
      math_engine: nil,
      syntax_highlighter: nil
    )
    html = doc.to_html
      .gsub("<table>", %(<div class="table-responsive"><table class="table table-bordered">))
      .gsub("</table>", "</table></div>")
    highlight_code_blocks(html).html_safe
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
