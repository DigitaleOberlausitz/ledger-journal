<?xml version="1.0" encoding="UTF-8" ?>
<x:stylesheet xmlns:x="http://www.w3.org/1999/XSL/Transform" version="1.1">
    <x:output method="html"/>
    <x:decimal-format decimal-separator="," grouping-separator="." name="de"/>
    <x:template match="/ledger">
        <html>
            <head>
                <meta name="robots" content="noindex" />
                <title>
                    <x:text>Finanzbuchhaltung </x:text>
                    <x:value-of select="substring(//account[substring(name, 5) = ' EBK']/name, 1, 4)"/>
                </title>
                <style type="text/css">
                    <x:text disable-output-escaping="yes">
                        * {padding: 0; margin: 0; font-family: sans-serif; font-style: normal}
                        a {text-decoration: none}
                        h1, p {margin: 1rem}
                        section {display: none}
                        section:target, #transactions, #balance {display: block}
                        section>header {margin: 4rem 1rem 0 1rem}
                        #transactions>header, #balance>header {margin: 2rem 1rem 0 1rem}
                        header>h2 {margin: 0}
                        table {margin: 2rem 0; empty-cells: show; border-collapse: collapse; border-spacing: 0}
                        section>table {margin-top: 0; vertical-align: initial}
                        th, td {text-align: left; padding: .5rem 1rem}
                        td {border: 1px none #ccc; border-style: solid none; vertical-align: top}
                        td.numeric, th.numeric {text-align: right; white-space: nowrap}
                        td.multiple {color: #aaa}
                        tr {background-color: #fff}
                        tr:target {background-color: #ff8; animation: highlight 1s ease 2s forwards}
                        tr.posting td {border-style: hidden; padding: .1rem 1rem}
                        tr.posting.last td {border-style: solid none; padding-bottom: .5rem}
                        td.pos {color: #898}
                        td.neg {color: #977}
                        #balance table {border-collapse: separate; margin: 0 .9rem 2rem .9rem}
                        #balance th {padding: 0 1rem}
                        #balance td {padding: .1rem .1rem}
                        #balance td.pos {color: #060}
                        #balance td.neg {color: #900}
                        .account-tree {color: #999}
                        tr.header td {padding-top: .5rem}
                        #balance td {border-style: none}
                        #balance tr.subtotal td {border-top: 3px double #000; padding-bottom: .5rem}
                        #balance tr.subtotal td.indent, #balance tr.subtotal td.numeric {border-top: 3px double transparent}
                        tr.header td.account-name {color: #999; font-style: italic}
                        tr.subtotal td.account-name {color: #999}
                        tr.subtotal td.account-name::before {content: "Summe "; font-weight: bold}
                        @keyframes highlight { 0% {background-color: #ff8} 100% {background-color: #fff} }
                    </x:text>
                </style>
            </head>
            <body>
                <h1>
                    <x:text>Finanzbuchhaltung </x:text>
                    <x:value-of select="substring(//account[substring(name, 5) = ' EBK']/name, 1, 4)"/>
                </h1>
                <p>Digitale Oberlausitz e. V. | Kontenrahmen: SKR49 | Geschäftsjahr: Kalenderjahr</p>
                <x:apply-templates select="accounts" mode="balance"/>
                <x:apply-templates select="transactions" />
                <x:apply-templates select="accounts" />
            </body>
        </html>
    </x:template>
    <x:template match="transactions">
        <section id="transactions">
            <x:if test="//account[account-total/amount/quantity != 0]">
                <header><h2>Buchungsjournal</h2></header>
            </x:if>
            <table>
                <thead>
                    <tr>
                        <th>Datum</th>
                        <th>Belegnr.</th>
                        <th>Beschreibung</th>
                        <th>Buchungskonto</th>
                        <th class="numeric">Betrag</th>
                        <th>Gegenkonto</th>
                        <th>Notiz</th>
                    </tr>
                </thead>
                <tbody>
                    <x:apply-templates/>
                </tbody>
            </table>
        </section>
    </x:template>
    <x:template match="transaction">
        <x:variable name="numPostings" select="count(postings/posting)"/>
        <x:variable name="creditPostings" select="postings/posting[post-amount/amount/quantity >= 0]"/>
        <x:variable name="debitPostings" select="postings/posting[post-amount/amount/quantity &lt; 0]"/>
        <x:variable name="total" select="sum(postings/posting/post-amount/amount/quantity[. >= 0])"/>
        <x:choose>
            <x:when test="$numPostings = 2">
                <tr id="tx{count(preceding-sibling::transaction) + 1}">
                    <td><x:value-of select="date"/></td>
                    <td><x:value-of select="code"/></td>
                    <td><x:value-of select="payee"/></td>
                    <td>
                        <a title="{$creditPostings/account/name}" href="#ac{$creditPostings/account/@ref}">
                            <x:value-of select="//account[@id = $creditPostings/account/@ref]/name"/>
                        </a>
                    </td>
                    <td class="numeric"><x:value-of select="format-number($total, '0,00€', 'de')"/></td>
                    <td>
                        <a title="{$debitPostings/account/name}" href="#ac{$debitPostings/account/@ref}">
                            <x:value-of select="//account[@id = $debitPostings/account/@ref]/name"/>
                        </a>
                    </td>
                    <td><x:value-of select="postings/posting/note"/></td>
                </tr>
            </x:when>
            <x:otherwise>
                <tr id="tx{count(preceding-sibling::transaction) + 1}">
                    <td rowspan="{$numPostings + 1}"><x:value-of select="date"/></td>
                    <td rowspan="{$numPostings + 1}"><x:value-of select="code"/></td>
                    <td rowspan="{$numPostings + 1}"><x:value-of select="payee"/></td>
                    <td class="multiple">...</td>
                    <td class="numeric"><x:value-of select="format-number($total, '0,00€', 'de')"/></td>
                    <td class="multiple">...</td>
                    <td/>
                </tr>
                <x:apply-templates select="$creditPostings"/>
                <x:apply-templates select="$debitPostings"/>
            </x:otherwise>
        </x:choose>
    </x:template>
    <x:template match="posting">
        <tr>
            <x:attribute name="class">
                <x:text>posting</x:text>
                <x:if test="post-amount/amount/quantity &lt; 0 and count(following-sibling::posting[post-amount/amount/quantity &lt; 0]) = 0"> last</x:if>
            </x:attribute>
            <td>
                <x:if test="post-amount/amount/quantity >= 0">
                    <a title="{account/name}" href="#ac{account/@ref}">
                        <x:value-of select="//account[@id = current()/account/@ref]/name"/>
                    </a>
                </x:if>
            </td>
            <td>
                <x:attribute name="class">
                    <x:text>numeric</x:text>
                    <x:choose>
                        <x:when test="post-amount/amount/quantity >= 0"> pos</x:when>
                        <x:otherwise> neg</x:otherwise>
                    </x:choose>
                </x:attribute>
                <x:value-of select="format-number(post-amount/amount/quantity, '+0,00€;-0,00€', 'de')"/>
            </td>
            <td>
                <x:if test="post-amount/amount/quantity &lt; 0">
                    <a title="{account/name}" href="#ac{account/@ref}">
                        <x:value-of select="//account[@id = current()/account/@ref]/name"/>
                    </a>
                </x:if>
            </td>
            <td><x:value-of select="note"/></td>
        </tr>
    </x:template>
    <x:template match="accounts">
        <x:apply-templates select=".//account[@id]"/>
    </x:template>
    <x:template match="account">
        <x:if test="//posting[account/@ref = current()/@id]">
            <section id="ac{@id}">
                <header>
                    <div class="account-tree"><x:value-of select="substring-before(fullname, name)"/></div>
                    <h2><x:value-of select="name"/></h2>
                </header>
                <table>
                    <thead>
                        <tr>
                            <th>Datum</th>
                            <th>
                                <x:choose>
                                    <x:when test="substring(name, 5) = ' EBK' or substring(name, 5) = ' SBK' or substring(name, 1, 5) = '9889 '">Gegenkonto</x:when>
                                    <x:otherwise>Belegnr.</x:otherwise>
                                </x:choose>
                            </th>
                            <th>Beschreibung</th>
                            <th>Soll</th>
                            <th>Haben</th>
                            <th>Saldo</th>
                        </tr>
                    </thead>
                    <tbody>
                        <x:apply-templates select="//posting[account/@ref = current()/@id]" mode="account"/>
                    </tbody>
                </table>
            </section>
        </x:if>
    </x:template>
    <x:template match="posting" mode="account">
        <x:variable name="total" select="post-amount/amount/quantity + sum(preceding::posting[account/@ref = current()/account/@ref]/post-amount/amount/quantity)"/>
        <x:variable name="transaction" select="count(../../preceding-sibling::transaction) + 1"/>
        <tr>
            <td><a href="#tx{$transaction}"><x:value-of select="../../date"/></a></td>
            <td>
                <x:choose>
                    <x:when test="substring(account/name, 5) = ' EBK' or substring(account/name, 5) = ' SBK' or substring(//account[@id = current()/account/@ref]/name, 1, 5) = '9889 '">
                        <x:variable name="otherAccId" select="../posting[account/@ref != current()/account/@ref]/account/@ref"/>
                        <a href="#ac{$otherAccId}"><x:value-of select="//account[@id = $otherAccId]/name"/></a>
                    </x:when>
                    <x:otherwise><a href="#tx{$transaction}"><x:value-of select="../../code"/></a></x:otherwise>
                </x:choose>
            </td>
            <td><a href="#tx{$transaction}"><x:value-of select="../../payee"/></a></td>
            <td class="numeric">
                <x:if test="post-amount/amount/quantity >= 0">
                    <x:value-of select="format-number(post-amount/amount/quantity, '0,00€', 'de')"/>
                </x:if>
            </td>
            <td class="numeric">
                <x:if test="post-amount/amount/quantity &lt; 0">
                    <x:value-of select="format-number(post-amount/amount/quantity, '0,00€;0,00€', 'de')"/>
                </x:if>
            </td>
            <td>
                <x:attribute name="class">
                    <x:text>numeric</x:text>
                    <x:choose>
                        <x:when test="$total >= 0"> pos</x:when>
                        <x:otherwise> neg</x:otherwise>
                    </x:choose>
                </x:attribute>
                <x:value-of select="format-number($total, '0,00€ S;0,00€ H', 'de')"/>
            </td>
        </tr>
    </x:template>
    <x:template match="accounts" mode="balance">
        <x:variable name="depths">
            <x:for-each select="//account">
                <x:sort select="count(ancestor::account)" order="descending"/>
                <x:value-of select="count(ancestor::account)"/>
                <x:text>|</x:text>
            </x:for-each>
        </x:variable>
        <x:variable name="dates">
            <x:for-each select="//transaction">
                <x:sort select="date" order="descending"/>
                <x:value-of select="date"/>
                <x:text>|</x:text>
            </x:for-each>
        </x:variable>
        <x:variable name="maxDepth" select="substring-before($depths, '|')"/>
        <x:variable name="maxDate" select="substring-before($dates, '|')"/>
        <x:if test="//account[account-total/amount/quantity != 0]">
            <section id="balance">
                <header>
                    <h2>Salden zum
                        <x:value-of select="$maxDate"/>
                    </h2>
                </header>
                <table>
                    <thead>
                        <tr>
                            <x:for-each select="//account[count(ancestor::account) = $maxDepth][1]/ancestor::account">
                                <th/>
                            </x:for-each>
                        </tr>
                    </thead>
                    <tbody>
                        <x:apply-templates select="account/account" mode="balance">
                            <x:with-param name="maxDepth" select="$maxDepth - 1"/>
                            <x:with-param name="depth" select="0"/>
                        </x:apply-templates>
                    </tbody>
                </table>
            </section>
        </x:if>
    </x:template>
    <x:template match="account" mode="balance">
        <x:param name="maxDepth"/>
        <x:param name="depth" select="count(ancestor::account)"/>
        <x:param name="name" select="name"/>
        <x:if test="descendant-or-self::account[account-total/amount/quantity != 0]">
            <x:variable name="relevantChildren" select="account[account-total/amount/quantity != 0]"/>
            <x:choose>
                <x:when test="count($relevantChildren) > 1">
                    <tr class="header">
                        <x:if test="$depth > 0">
                            <td class="indent" colspan="{$depth}"/>
                        </x:if>
                        <td class="account-name" colspan="{$maxDepth + 1 - $depth}"><x:value-of select="$name"/></td>
                    </tr>
                    <x:apply-templates select="$relevantChildren" mode="balance">
                        <x:with-param name="maxDepth" select="$maxDepth"/>
                        <x:with-param name="depth" select="$depth + 1"/>
                    </x:apply-templates>
                </x:when>
                <x:otherwise>
                    <x:apply-templates select="$relevantChildren" mode="balance">
                        <x:with-param name="maxDepth" select="$maxDepth"/>
                        <x:with-param name="name" select="$name"/>
                        <x:with-param name="depth" select="$depth"/>
                    </x:apply-templates>
                </x:otherwise>
            </x:choose>
            <x:if test="count($relevantChildren) != 1">
                <tr>
                    <x:if test="$relevantChildren">
                        <x:attribute name="class">subtotal</x:attribute>
                    </x:if>
                    <x:if test="$depth > 0">
                        <td class="indent" colspan="{$depth}"/>
                    </x:if>
                    <td class="account-name" colspan="{$maxDepth + 1 - $depth}">
                        <x:choose>
                            <x:when test="$relevantChildren"><x:value-of select="$name"/></x:when>
                            <x:otherwise>
                                <a title="{fullname}" href="#ac{@id}"><x:value-of select="name"/></a>
                            </x:otherwise>
                        </x:choose>
                    </td>
                    <x:if test="$maxDepth + 1 > $depth">
                        <td colspan="{$maxDepth + 1 - $depth}"/>
                    </x:if>
                    <td>
                        <x:attribute name="class">
                            <x:text>numeric</x:text>
                            <x:choose>
                                <x:when test="account-total/amount/quantity >= 0"> pos</x:when>
                                <x:otherwise> neg</x:otherwise>
                            </x:choose>
                        </x:attribute>
                        <x:value-of select="format-number(account-total/amount/quantity, '0,00€ S;0,00€ H', 'de')"/>
                    </td>
                </tr>
            </x:if>
        </x:if>
    </x:template>
    <x:template match="*"/>
</x:stylesheet>
