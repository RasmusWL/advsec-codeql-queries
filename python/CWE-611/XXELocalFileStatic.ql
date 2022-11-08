/**
 * @name Resolving XML external entity in local file
 * @description Parsing local file XML data and allowing expansion of external entity
 * references may lead to disclosure of confidential data or denial of service.
 * @kind problem
 * @problem.severity error
 * @security-severity 6.0
 * @precision high
 * @id python/xxe-local-file-static
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-776
 *       external/cwe/cwe-827
 */

private import python
private import semmle.python.dataflow.new.DataFlow
private import XXELocalLib

from DataFlow::Node source, DataFlow::Node sink
where exists(XmlParseFileCall call|
  source = call.getSource()
  and sink = call
)
select sink, "Unsafe parsing of XML from fixed file name $@.", source,
  source.asExpr().(StrConst).getLiteralValue().toString()
