module RedmineLatexMathjax
  module Hooks
    class ViewLayoutsBaseHtmlHeadHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
          return "<script>
MathJax = {
  options: {
    ignoreHtmlClass: 'tex2jax_ignore',
    processHtmlClass: 'tex2jax_process'
  },
  tex: {
    autoload: {
      color: [],
      colorv2: ['color']
    },
    //packages: {'[+]': ['noerrors', 'require']},
    packages: {'[+]': ['noerrors']},
    inlineMath: [ ['" + MathJaxEmbedMacro.delimiterStartInline.html_safe + "','" + MathJaxEmbedMacro.delimiterEndInline.html_safe + "'], ['\\\\(', '\\\\)'] ],
    displayMath: [             // start/end delimiter pairs for display math
      ['$$', '$$'], ['\\[', '\\]']
    ],
  },
  loader: {
    //source: {
    //  'xyjax': \"http://sonoisa.github.io/xyjax_ext/xypic.js\"
    //},
    //load: ['[tex]/noerrors', '[tex]/require', 'xyjax' ]
    load: ['[tex]/noerrors'],
  },
  startup: {
    ready: () => {
      console.log('NEW 4: MathJax is loaded, but not yet initialized');
      MathJax.startup.defaultReady();
      console.log('MathJax is initialized, and the initial typeset is queued');
      MathJax.startup.promise.then(() => {
        console.log('MathJax initial typesetting complete');
      });
    }
  }
  };
  //MathJax.typeset();
</script>\n" +
            javascript_include_tag(MathJaxEmbedMacro.URLToMathJax) + "
<script type=\"text/javascript\">
  // Own submitPreview script with Mathjax trigger. Copy & Paste of public/javascripts/application.js
  function MJsubmitPreview(url, form, target) {
	$.ajax({
  	  url: url,
  	  type: 'post',
  	  data: $('#'+form).serialize(),
  	  success: function(data){
    	$('#'+target).html(data);
    	MathJax.typeset();
  	  }
	});
  }
  // Replace function submitPreview with own version with a Mathjax trigger
  document.addEventListener(\"DOMContentLoaded\", function() {
	a = document.getElementsByTagName(\"a\");
    for( var x=0; x < a.length; x++ ) {
      if ( a[x].onclick ) {
        str = a[x].getAttribute(\"onclick\");
        if (str.indexOf(\"submitPreview\") === 0) {
      	  a[x].setAttribute(\"onclick\", str.replace(\"submitPreview\",\"MJsubmitPreview\"));
          break;
      	};
      };  
	};	
  });
</script>"
      end
    end
  end
end
