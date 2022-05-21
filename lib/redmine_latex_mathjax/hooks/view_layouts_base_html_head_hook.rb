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
      colorV2: ['color']
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
    //
    //  Mapping of old extension names to new ones
    //
    requireMap: {
      AMSmath: 'ams',
      AMSsymbols: 'ams',
      AMScd: 'amscd',
      HTML: 'html',
      noErrors: 'noerrors',
      noUndefined: 'noundefined'
    },
    ready: function () {
      //
      //  Replace the require command map with a new one that checks for
      //    renamed extensions and converts them to the new names.
      //
      var CommandMap = MathJax._.input.tex.SymbolMap.CommandMap;
      var requireMap = MathJax.config.startup.requireMap;
      var RequireLoad = MathJax._.input.tex.require.RequireConfiguration.RequireLoad;
      var RequireMethods = {
        Require: function (parser, name) {
          var required = parser.GetArgument(name);
          if (required.match(/[^_a-zA-Z0-9]/) || required === '') {
            throw new TexError('BadPackageName', 'Argument for %1 is not a valid package name', name);
          }
          if (requireMap.hasOwnProperty(required)) {
            required = requireMap[required];
          }
          RequireLoad(parser, required);
        }
      };
      new CommandMap('require', {require: 'Require'}, RequireMethods);
      //
      //  Do the usual startup
      //
      //return MathJax.startup.defaultReady();
      console.log('NEW 5: MathJax is loaded, but not yet initialized');
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
