<%
/**
 * Copyright (c) 2000-2010 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
%>

<%@ include file="/admin/init.jsp" %>

<%
Article article = (Article)request.getAttribute(WebKeys.KNOWLEDGE_BASE_ARTICLE);

int sourceVersion = ParamUtil.getInteger(request, "sourceVersion", (article.getVersion() != ArticleConstants.DEFAULT_VERSION) ? (article.getVersion() - 1) : article.getVersion());
int targetVersion = ParamUtil.getInteger(request, "targetVersion", article.getVersion());
%>

<liferay-util:include page="/admin/top_links.jsp" servletContext="<%= application %>" />

<liferay-portlet:renderURL varImpl="compareVersionsURL">
	<portlet:param name="jspPage" value="/admin/history.jsp" />
</liferay-portlet:renderURL>

<aui:form action="<%= compareVersionsURL %>" method="get" name="fm" onSubmit='<%= "event.preventDefault(); " + renderResponse.getNamespace() + "compare();" %>'>
	<liferay-portlet:renderURLParams varImpl="compareVersionsURL" />
	<aui:input name="resourcePrimKey" type="hidden" value="<%= article.getResourcePrimKey() %>" />
	<aui:input name="sourceVersion" type="hidden" value="<%= sourceVersion %>" />
	<aui:input name="targetVersion" type="hidden" value="<%= targetVersion %>" />

	<liferay-ui:search-container
		delta="<%= 100 %>"
		headerNames="version,date,author,title"
		rowChecker="<%= new RowChecker(renderResponse, RowChecker.ALIGN, RowChecker.VALIGN, RowChecker.FORM_NAME, null, RowChecker.ROW_IDS) %>"
	>
		<liferay-ui:search-container-results
			results="<%= ArticleServiceUtil.getArticles(article.getResourcePrimKey(), searchContainer.getStart(), searchContainer.getEnd(), new ArticleVersionComparator()) %>"
			total="<%= ArticleServiceUtil.getArticlesCount(article.getResourcePrimKey()) %>"
		/>

		<liferay-ui:search-container-row
			className="com.liferay.knowledgebase.model.Article"
			keyProperty="version"
			modelVar="curArticle"
		>
			<portlet:renderURL var="rowURL">
				<portlet:param name="jspPage" value="/admin/history.jsp" />
				<portlet:param name="resourcePrimKey" value="<%= String.valueOf(curArticle.getResourcePrimKey()) %>" />
				<portlet:param name="sourceVersion" value="<%= String.valueOf(curArticle.getVersion()) %>" />
				<portlet:param name="targetVersion" value="<%= String.valueOf(curArticle.getVersion()) %>" />
			</portlet:renderURL>

			<liferay-ui:search-container-column-text
				href="<%= rowURL %>"
				name="version"
			>
				<%= curArticle.getVersion() %>

				<c:choose>
					<c:when test="<%= (curArticle.getVersion() == sourceVersion) && (curArticle.getVersion() == targetVersion) %>">
						(<liferay-ui:message key="selected" />)
					</c:when>
					<c:when test="<%= curArticle.getVersion() == sourceVersion %>">
						(<liferay-ui:message key="source" />)
					</c:when>
					<c:when test="<%= curArticle.getVersion() == targetVersion %>">
						(<liferay-ui:message key="target" />)
					</c:when>
				</c:choose>
			</liferay-ui:search-container-column-text>

			<liferay-ui:search-container-column-text
				href="<%= rowURL %>"
				name="date"
				value="<%= dateFormatDateTime.format(curArticle.getModifiedDate()) %>"
			/>

			<liferay-ui:search-container-column-text
				href="<%= rowURL %>"
				name="author"
				property="userName"
			/>

			<liferay-ui:search-container-column-text
				href="<%= rowURL %>"
				property="title"
			/>

			<c:if test="<%= ArticlePermission.contains(permissionChecker, article, ActionKeys.UPDATE) %>">
				<liferay-ui:search-container-column-text
					align="right"
				>
					<portlet:renderURL var="historyURL">
						<portlet:param name="jspPage" value="/admin/history.jsp" />
						<portlet:param name="resourcePrimKey" value="<%= String.valueOf(article.getResourcePrimKey()) %>" />
					</portlet:renderURL>

					<portlet:actionURL name="updateArticle" var="revertURL">
						<portlet:param name="jspPage" value="/admin/history.jsp" />
						<portlet:param name="redirect" value="<%= historyURL %>" />
						<portlet:param name="resourcePrimKey" value="<%= String.valueOf(article.getResourcePrimKey()) %>" />
						<portlet:param name="parentResourcePrimKey" value="<%= String.valueOf(article.getParentResourcePrimKey()) %>" />
						<portlet:param name="title" value="<%= curArticle.getTitle() %>" />
						<portlet:param name="content" value="<%= curArticle.getContent() %>" />
						<portlet:param name="description" value="<%= curArticle.getDescription() %>" />
						<portlet:param name="priority" value="<%= String.valueOf(article.getPriority()) %>" />
					</portlet:actionURL>

					<liferay-ui:icon
						image="undo"
						label="<%= true %>"
						message="revert"
						url="<%= revertURL %>"
					/>
				</liferay-ui:search-container-column-text>
			</c:if>
		</liferay-ui:search-container-row>

		<div class="float-container kb-entity-header">
			<div class="kb-title">
				<%= KnowledgeBaseUtil.getArticleDiff(article.getResourcePrimKey(), sourceVersion, targetVersion, "title", null) %>
			</div>

			<div class="kb-tools">
				<portlet:renderURL var="viewArticleURL">
					<portlet:param name="jspPage" value="/admin/view_article.jsp" />
					<portlet:param name="resourcePrimKey" value="<%= String.valueOf(article.getResourcePrimKey()) %>" />
				</portlet:renderURL>

				<liferay-ui:icon
					image="../common/page"
					label="<%= true %>"
					message="latest-version"
					url="<%= viewArticleURL %>"
				/>
			</div>
		</div>

		<div class="kb-entity-body">
			<%= KnowledgeBaseUtil.getArticleDiff(article.getResourcePrimKey(), sourceVersion, targetVersion, "content", null) %>
		</div>

		<div class="kb-entity-footer">
			<liferay-ui:panel-container extended="<%= false %>" id='<%= "knowledgeBaseArticle" + article.getResourcePrimKey() + "VersionHistoryPanelContainer" %>' persistState="<%= true %>">
				<liferay-ui:panel collapsible="<%= true %>" extended="<%= true %>" id='<%= "knowledgeBaseArticle" + article.getResourcePrimKey() + "VersionHistoryPanel" %>' persistState="<%= true %>" title='<%= LanguageUtil.get(pageContext, "version-history") %>'>
					<aui:button-row>
						<aui:button type="submit" value="compare-versions" />
					</aui:button-row>

					<liferay-ui:search-iterator />
				</liferay-ui:panel>
			</liferay-ui:panel-container>
		</div>
	</liferay-ui:search-container>
</aui:form>

<aui:script>
	Liferay.provide(
		window,
		'<portlet:namespace />compare',
		function() {
			var A = AUI();

			var rowIds = A.all('input[name=<portlet:namespace />rowIds]:checked');
			var sourceVersion = A.one('input[name="<portlet:namespace />sourceVersion"]');
			var targetVersion = A.one('input[name="<portlet:namespace />targetVersion"]');

			var rowIdsSize = rowIds.size();

			if (rowIdsSize == 1) {
				if (sourceVersion) {
					sourceVersion.val(rowIds.item(0).val());
				}
			}
			else if (rowIdsSize == 2) {
				if (sourceVersion) {
					sourceVersion.val(rowIds.item(1).val());
				}

				if (targetVersion) {
					targetVersion.val(rowIds.item(0).val());
				}
			}

			submitForm(document.<portlet:namespace />fm);
		},
		['aui-base', 'selector-css3']
	);

	Liferay.provide(
		window,
		'<portlet:namespace />initRowsChecked',
		function() {
			var A = AUI();

			var rowIds = A.all('input[name=<portlet:namespace />rowIds]');

			rowIds.each(
				function(item, index, collection) {
					if (index >= 2) {
						item.set('checked', false);
					}
				}
			);
		},
		['aui-base']
	);

	Liferay.provide(
		window,
		'<portlet:namespace />updateRowsChecked',
		function(element) {
			var A = AUI();

			var rowsChecked = A.all('input[name=<portlet:namespace />rowIds]:checked');

			if (rowsChecked.size() > 2) {
				var index = 2;

				if (rowsChecked.item(2).compareTo(element)) {
					index = 1;
				}

				rowsChecked.item(index).set('checked', false);
			}
		},
		['aui-base', 'selector-css3']
	);
</aui:script>

<aui:script use="aui-base">
	<portlet:namespace />initRowsChecked();

	A.all('input[name=<portlet:namespace />rowIds]').on(
		'click',
		function(event) {
			<portlet:namespace />updateRowsChecked(event.currentTarget);
		}
	);
</aui:script>